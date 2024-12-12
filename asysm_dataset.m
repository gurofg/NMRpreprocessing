function [korrigert_asysm] = asysm_dataset(matrix, lambda, p, d,figure);

% [korrigert_asysm] = asysm_dataset(matrix, lambda, p, d, figure);
% performs asysm baseline correction on whole data set
% input: matrix = your dataset
%        lambda: smoothing parameter (generally 1e5 to 1e8) (high = less
%                                                               flexible)
%        p:      asymmetry parameter (generally 0.0001)
%        d:      order of differences in penalty (generally 2)
%       figure:  1: draw figure of all spectra with estimated baseline (one and one),
%                 press enter to continue to new spectrum 
%                2: no figures.
% output: korrigert_asysm = dataset baseline corrected using asysm



z = []; 
korrigert_asysm = [];
a = size(matrix,1);
for i = 1:a
    z(:,i) = asysm(matrix(i,:)', lambda, p, d);
    zz = z';
    korrigert_asysm(i,:) = matrix(i,:) - zz(i,:);
end

if figure == 1;
    fprintf('proceed to next figure by pressing enter\n');
    for i = 1:a %plott en og en for å se på baselinjen
        maxY = max(matrix(i,:))/10;
        plot(matrix(i,:),'b')
        %ylim([-10 maxY]);
        hold on
        plot(zz(i,:),'r')
        title(num2str(i))
        
    pause

    close
    end
    
    elseif figure == 2
end


end

% for i = 1:a %plott en og en for å se på baselinjen
% plot(matrix(i,:),'b')
% hold on
% plot(zz(i,:),'r')
% title(num2str(i))
% 
% pause
% 
% close
% 
% end
