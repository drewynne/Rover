% New read data from bessy
% edited because the array now is printed within a single line


clc

delete(instrfindall); % clear any com ports that are still open
port = 'COM5';
s = serial(port);
set(s, 'BaudRate', 115200);
fopen(s);

%%

% search for 'Beginning Loop...'

fprintf('Searching for beginning of loop\n');

loopStarted = 0;
while loopStarted == 0;
    out = fscanf(s);
    fprintf(out);
    fprintf('\n');
    if(strfind(out, 'Beginning Loop...') == 1);
        loopStarted = 1;
    end
end

 % out = fscanf(s);
 
 
%%

% find Data from arduino

dataLable = 'Data Array For Current Pass:';
angle = 0;
angleLable = 'Best Angle = ';
keepGoing = 1;

while keepGoing == 1;
    out = fscanf(s);

    if(strfind(out, dataLable) == 1);
        % remove 'Data Array For Current Pass:' from data
        
        out(1: length(dataLable))  = [];
        fprintf(out);
        data = sscanf(out, '%f');
        for k = 1: length(data);
            % display(data(k));
        end
    end
    

    for k = 1: 2;
            
        out = fscanf(s);
        fprintf(out);
        if(strfind(out, angleLable) == 1);
            out(1: length(angleLable)) = [];
            angle = sscanf(out, '%d');
            
            display(angle);
            if(angle < -90 || angle > 90);
                angle = NaN;
            end
            angle = deg2rad(- 90 - angle);
            display(angle);
        end
    end

    
    
    
    %% plot
    clf
    theta = 90: -10: -(90);
    
    % grid on;
    anglePlot = angle.*ones(1, 2);
    distPlot = [0, max(data)];
    
    beta = 0: -0.1: -pi;
    oneMetre = ones(1, length(beta));
    axis equal;
    polarplot(deg2rad(theta - 90), data', 'b'); % plot data
    hold on;
    polarplot(anglePlot, distPlot, 'r'); % plot best angle
    polarplot(beta, oneMetre, 'g'); % plot one metre radius
    
    legend('Distance Data', 'Current Best Travel Angle', 'One Metre', ...
        'location', 'southoutside');
    title('Ping Data From Robot');
    hold off;
    
    %%
    keepGoing = input('keep going?, 1 for yes 0 for no ');
end


fprintf('closing program\n');





%% close serial port
fclose(s);
delete(s);
clear s port;

% print(figure(1), '-dpng', '-r300', 'Ping_Data_From_Robot.png');

