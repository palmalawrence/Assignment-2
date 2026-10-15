start_toolkit
d=epanet('hub.inp');
d.plot
d.plot('point', 'no');
d.plot('nodes', 'yes', 'fontsize', 12)
d.plot('links', 'yes', 'fontsize', 12)
d.plot('linksindex', 'yes', 'fontsize',8);
d.plot('line', 'no');
d.plot('nodesindex', 'yes', 'fontsize',14);
d.plot('point', 'no');
d.plot('legend', 'hide')
d.plot('extend', 'yes')
d.plot('legendposition', 'EastOutside')
nodeSet1 = d.getNodeNameID(1:4);
colorLinkSet1 = repmat({'y'},1,length(nodeSet1));
nodeSet2 = d.getNodeNameID([5,6,7,8]);
colorLinkSet2=repmat({'g'},1,length(nodeSet2));
d.plot('highlightnode',[nodeSet1 nodeSet2],'colornode',[colorLinkSet1 colorLinkSet2])
h = figure;
d.plot('axes', h)
% Plot for matlab apps (GUIs)
%d.plot('uifigure', app.UIFigure, 'axes', app.UIAxes,'legend','hide');
h = d.plotGraph;
title('Network Graph');
d.plotGraph('nodes', 'yes'); % Show ID of nodes
title('Network Graph with node IDs');
d.setQualityType('Chlorine', 'mg/L');
initialQuality = 0.6;
nodeIndex = d.getNodeReservoirIndex;
nodeIndex = [nodeIndex d.getNodeTankIndex];

d.setNodeInitialQuality(nodeIndex, initialQuality * ones(length(nodeIndex),1))
d.openHydraulicAnalysis;
d.openQualityAnalysis;
d.initializeHydraulicAnalysis(0);
d.initializeQualityAnalysis(d.ToolkitConstants.EN_NOSAVE);
hyd_res = d.getComputedHydraulicTimeSeries('time', 'pressure', 'flow', 'velocity');
hrs_time = hyd_res.Time/3600;
node_indices = [1, 3, 5];
node_names = d.getNodeNameID(node_indices);
units = d.getUnits;
for i=node_indices
    figure;
    plot(hrs_time, hyd_res .Pressure(:,i));
    title(['Pressure for the node id "', d.getNodeNameID{i},'"']);
    xlabel('Time (hrs)'); 
    ylabel(['Pressure (', units.NodePressureUnits,')'])
end
fig = d.plot('legend', 'hide');
format long g
time_step = 22;
flow=hyd_res.Flow(time_step,:);
fontweight = 'bold';
fontsize = 10;
for i = d.getLinkIndex
    value = flow(i);    
    FromNode=strfind(strcmp(nodesconnlinks(i, 1), nodenameid), 1);
    ToNode=strfind(strcmp(nodesconnlinks(i, 2), nodenameid), 1);

    if FromNode
        x1 = double(nodecoords{1}(FromNode));
        y1 = double(nodecoords{2}(FromNode));
    end
    if ToNode
        x2 = double(nodecoords{1}(ToNode));
        y2 = double(nodecoords{2}(ToNode));
    end
    F = line([x1 nodecoords{3}{i} x2], [y1 nodecoords{4}{i} y2], 'LineWidth', 1, 'Color', color, 'Parent', fig);
    text((x1+x2)/2-xsenoff, (y1+y2)/2+ysenoff, num2str(value, '%.5f'), 'FontWeight', fontweight, 'Fontsize', fontsize, 'color', color)
end
figure;
subplot(2,1,1);
plot(Results.Time, Results.Pressure(:,indexNode));
title('Before set curve');
xlabel('Time (hrs)'); 
ylabel(['Pressure (', d.NodePressureUnits,')'])  
Flows = F(:, link_index);
T = table(Flows, Status);
fprintf('\nFlows and status for node index 2:\n')
T;
pipe_count = d.getLinkPipeCount;
pipe_indices = d.getLinkPipeIndex;
d.openHydraulicAnalysis;
d.initializeHydraulicAnalysis;
i=1;tstep=1; F=[];
