[rampingNeurons] = central_function_ramping_neurons(allMiceData, [-4 -3], [-.33 0], 'PC');
rampingInds = find(rampingNeurons(1).allDelayActiveNeurons > 0);

[csStruct] = analyze_context_modulated_neurons(allMiceData, [0 1], [-4 -3]);
close all

[pe_inds] = find_pe_inds(csStruct);

overlap = length(intersect(pe_inds, rampingInds));
venn([length(pe_inds) length(rampingInds)], overlap)

% pe_ramping_venn(length(pe_inds), length(rampingInds), overlap)
% 
% function [] = pe_ramping_venn(A, B, AB)
% 
% 
% % Normalize to ensure total is 100%
% total = A + B - AB; 
% A_only = A - AB;
% B_only = B - AB;
% 
% % Check if sum is 100% (should be true)
% assert(abs(A_only + B_only + AB - 100) < 1e-5, 'Error: Proportions do not sum to 100%');
% 
% % Create the Venn diagram
% figure;
% venn([A/100, B/100], AB/100, 'FaceAlpha', 0.5);
% 
% % Annotate with percentages
% text(-0.6, 0, sprintf('%.1f%%', A_only), 'FontSize', 14, 'FontWeight', 'bold');
% text(0.6, 0, sprintf('%.1f%%', B_only), 'FontSize', 14, 'FontWeight', 'bold');
% text(0, 0, sprintf('%.1f%%', AB), 'FontSize', 14, 'FontWeight', 'bold', 'Color', 'r');
% 
% title('Proportional Venn Diagram (Sum = 100%)', 'FontSize', 14);
% end




function [pe_inds] = find_pe_inds(csStruct)
for ind = 1:size(csStruct,2)
    % odor response
    csPlusResponses(ind) = csStruct(ind).CSplus.odor_response;
    csMinusResponses(ind) = csStruct(ind).CSminus.odor_response;
    
    %context modulated
    csPlus_context_mod(ind) = csStruct(ind).CSplus.h_context_modulated;
    csMinus_context_mod(ind) = csStruct(ind).CSminus.h_context_modulated;
    
    csPlus_H_L_fr(:,ind) = [(csStruct(ind).CSplus.H_fr) ; (csStruct(ind).CSplus.L_fr)];
    csMinus_H_L_fr(:,ind) = [(csStruct(ind).CSminus.H_fr) ; (csStruct(ind).CSminus.L_fr)];
    
    csPlus_H_rasters{ind} = csStruct(ind).CSplus.H_raster;
    csPlus_L_rasters{ind} = csStruct(ind).CSplus.L_raster;
    
    csMinus_H_rasters{ind} = csStruct(ind).CSminus.H_raster;
    csMinus_L_rasters{ind} = csStruct(ind).CSminus.L_raster;
end

%% Venn of odor responses
bothResponding = csPlusResponses.*csMinusResponses;
venn([sum(csPlusResponses) sum(csMinusResponses)], sum(bothResponding))

%%
%% number of context modulated
csPlus_response_and_modulated = csPlus_context_mod.*csPlusResponses;
csMinus_response_and_modulated = csMinus_context_mod.*csMinusResponses;

pe_inds = unique([find(csPlus_response_and_modulated > 0) find(csMinus_response_and_modulated > 0)]);
end