h_rt = [];h_rt(1) = 0;l_rt = 0;
for ind = 1:length(output.CS_plus_minus)-1
    if output.CS_plus_minus(ind)
        if output.H_L_vec(ind)
            h_rt(ind) = output.firstLickLatency(ind);
        else
            l_rt(ind) = output.firstLickLatency(ind);
        end
    else
        if output.H_L_vec(ind)
            h_rt(ind) = h_rt(end);
        else
            l_rt(ind) = l_rt(end);
        end
    end
end
smoothFactor = 10;
figure;
plot(h_rt)
plot(smooth(h_rt,smoothFactor), 'Color', [0,169,137]./255)
hold on;
plot(smooth(l_rt,smoothFactor), 'Color', [171,62,143]./255)