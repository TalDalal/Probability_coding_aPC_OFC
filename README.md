# State-transition-model fitting pipeline

## Files
- `loadMouseData.m` — concatenates a mouse's sessions into one chronological trial table
- `fitBehaviorModels.m` — fits 5 models (Null, Flat/RW, TD-chain, Bayesian, Hybrid) by MLE, returns AIC/BIC
- `analyzeLearning.m` — per-session learning curves (A−B lick-prob. difference), exponential acquisition fit, trial-history GLM
- `runAllMice.m` — driver script, loops over `allMiceBehavior`, makes group plots

Run order: load `allMiceBehavior` → `runAllMice`.

## Three things to confirm before trusting the numbers

1. **RT/lick-latency field.** You mentioned RT is your main proxy for "has the mouse learned the transition model," but the fields you listed (`sessNum`, `Atrials`, `Btrials`, `sufficientLicks`, `CS_plus_minus`) don't include a continuous latency. `loadMouseData.m` auto-searches common names (`RT`, `latency`, `lickLatency`, ...) and falls back to all-NaN with a warning if none match. **What's the actual field name, and is it measured relative to context-odor onset (the cleanest test — differential expectation *before* the CS is even shown) or relative to CS onset?** Once I know this I'll add the DDM/vigor-style analysis (drift rate ~ value, and the variance-shrinkage test below) — that part isn't built yet since I didn't want to guess wrong and waste your time re-running things.

2. **Atrials/Btrials indexing.** I assumed these are indices into the *same, full, chronologically-ordered* per-session arrays as `CS_plus_minus`/`sufficientLicks` (i.e. `CS_plus_minus(Atrials)` gives you the CS types on A-context trials, in order). If instead they index into some other array, the context/CS/reward alignment in `loadMouseData.m` will be wrong — worth a quick sanity check (e.g. `length(Atrials)+length(Btrials) == length(CS_plus_minus)`).

3. **Reward contingency.** I assumed reward is delivered on 100% of CS+ trials regardless of licking (true Pavlovian). If reward actually requires `sufficientLicks==1`, flip `REWARD_CONTINGENT_ON_LICK` to `true` at the top of `loadMouseData.m`.

## The models

All 5 produce a trial-by-trial **prospective** context value V(t) (computed only from trials before t), mapped through a logistic link to predict `sufficientLicks`:

- **Null** — no learning, just a fixed A/B effect (floor model)
- **Flat** — Rescorla-Wagner value of context, updated directly from trial reward
- **TD-chain** — context value bootstraps off the *value of the CS just revealed*, not off reward directly; CS value itself learns from reward (this is the literal "second-order conditioning / chained prediction" story)
- **Bayesian** — explicit Beta-Bernoulli belief over P(CS+|context), with a leak/forgetting parameter (model-based)
- **Hybrid** — w·Bayesian + (1−w)·Flat, with w fit per mouse as your individual-differences readout

## Important caveat: Flat vs. TD-chain will look very similar here

Because CS→reward is **deterministic** (100% validity) in this task, once CS+ value has converged to ~1, the TD-chain's context update (`bootstrap off V(CS)`) becomes numerically almost identical to the Flat model's update (`bootstrap off reward directly`) — there's no genuine intermediate uncertainty for the chained model to add value over the direct one. So a small Flat-vs-TDchain AIC difference is *expected* even if the mouse truly represents the two-stage structure, and shouldn't be over-interpreted as evidence against a state-transition model. The Bayesian-vs-model-free comparison, and the following behavioral signature, are the sharper tests.

## The sharpest available dissociation: variance, not just mean

A fixed-learning-rate RW/TD value has roughly constant trial-to-trial noise around its estimate throughout learning. A true Bayesian learner's *posterior* concentrates with experience — its uncertainty shrinks roughly as 1/n. If the mouse is doing something closer to genuine probabilistic inference over the transition structure, you'd expect:
- RT variance (or lick-probability variance) on A vs. B trials to **shrink across sessions even after the mean A−B difference has plateaued**
- Whereas a pure fixed-α RW/TD-chain model predicts that variance stays roughly flat once the mean asymptotes

This is worth checking directly in your existing data (no new experiment needed) and is exactly the kind of result reviewers tend to find convincing for "the animal represents structure," since it doesn't require assuming which model produced the mean effect.

## Suggestions from before that aren't (fully) built yet, and why

- **Neural correlates** — not applicable without recording data, but if you have any, trial-by-trial `Vctx` output from `fitBehaviorModels.m`/`fitRTModels.m` (or the RPE, `reward(t) - Vctx(t)`) is ready to regress against neural signals.

## Update: now using the actual lick-raster data (`lickRaster(trial).times`)

`loadMouseData.m` now extracts, per trial, from `allMiceBehavior(m).data(s).lickRaster(trial).times` (lick times relative to CS onset at t=0; context odor on from −2 to −1):

| Column | Window (rel. to CS) | Meaning |
|---|---|---|
| `RT` | `[-2, 0)` | latency to first lick after **context-odor onset** — the primary DV, precedes the CS entirely |
| `nLicks_context` | `[-2, 0)` | count in that window (well-defined even with 0 licks — no missing-data issue) |
| `RT_trace` | `[-1, 0)` | latency to first lick after **context-odor offset** — purest anticipation, no odor physically present anymore |
| `nLicks_trace` | `[-1, 0)` | count in that window |
| `RT_CS` | `[0, 2)` | latency to first lick after CS onset |
| `nLicks_CS` | `[0, 2)` | count in that window |

**Assumption to confirm:** `lickRaster(trial)` uses the same chronological trial numbering as `CS_plus_minus`/`Atrials`/`Btrials`. Also worth eyeballing a couple of raw rasters to confirm the −2/−1 odor-on window matches what's actually in the data (I'm going by panel b of your figure).

### `fitRTModels.m` — the same 5 models, now fit to real RT

Fits **promptness = 1/RT** (LATER-model framework: linear-in-value, roughly Gaussian, standard for treating lick/saccade latencies) as a function of each model's `Vctx(t)`, same Null/Flat/TDchain/Bayesian/Hybrid registry (shared via `getValueModels.m` so the licking-based and RT-based fits use *identical* value definitions). Learning-rate/weight parameters fit by `fminsearch`; the linear link is closed-form OLS (`\`), so nothing beyond base MATLAB is required. Call with `'dvColumn','RT_trace'` to check robustness against the CS-adjacent confound in the full context window.

Trials with no anticipatory lick get `RT = NaN` and are dropped listwise for this fit — if that drops a lot of early/novice-stage trials, `nLicks_context` (via a logistic model, same pattern as `fitBehaviorModels.m`) is the fallback DV that has no missingness.

### `analyzeRTVariance.m` — the variance-shrinkage test

This is the sharper, model-agnostic dissociation flagged earlier: does `Var(promptness)` on A/B trials keep **shrinking across sessions even after the mean A−B difference has plateaued**? A fixed-α RW/TD-chain model can't produce that (noise stays ~constant once the mean asymptotes); a genuine Bayesian learner's posterior concentrates with experience. The function also outputs `bayesPredictedVarPooled` — the normative Beta-posterior variance trajectory — so you can overlay observed vs. predicted shrinkage directly rather than just eyeballing a downward trend.

`runAllMice.m` now runs all of this automatically whenever `lickRaster` is detected, and produces an RT-based model-comparison plot plus the variance-shrinkage plot alongside the licking-based ones.
