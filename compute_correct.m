function correct = compute_correct(cs, lick)
% cs:   Nx1 (1=CS+, 0=CS-)
% lick: Nx1 (1=lick, 0=no lick)

% force column vectors
cs   = cs(:);
lick = lick(:);

% correctness
correct = (cs == lick);

% convert logical → double (0/1)
correct = double(correct);

end