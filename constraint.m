clear; clc; close all;
stecFile = 'C:\Users\stec845_inbound.txt';
siteNameCol = 3; lonCol = 8; latCol = 9;
filterLonRange = [110, 130]; filterLatRange = [25, 35];
specificSiteNames = ["DAIS","JIND","JIAX","ZJCX","QZJS","FEHU","ZJXJ","TAIZ","ZHUJ"];
mapDisplayLonLim = [117.75, 122.75];
mapDisplayLatLim = [26.75, 31.75];
allSiteNames = {}; allLons = []; allLats = [];
try
    if ~exist(stecFile, 'file'), error('file %s can not be found', stecFile); end
    rawLines = readlines(stecFile); rawLines = rawLines(strlength(strtrim(rawLines)) > 0);
    if isempty(rawLines), error('file %s is null', stecFile); end
    for i = 1:length(rawLines)
        parts = strsplit(rawLines(i), ',');
        if numel(parts) >= max([siteNameCol, lonCol, latCol])
            try
                siteName = strtrim(parts{siteNameCol});
                lon = str2double(strtrim(parts{lonCol}));
                lat = str2double(strtrim(parts{latCol}));
                if ~isempty(siteName) && ~isnan(lon) && ~isnan(lat)
                    allSiteNames{end+1,1} = siteName;
                    allLons(end+1,1) = lon;
                    allLats(end+1,1) = lat;
                end
            catch
            end
        end
    end
catch ME
    fprintf('error: %s\n', ME.message);
    return;
end
[uniqueNames, firstIdx, ~] = unique(allSiteNames, 'stable');
uniqueLons = allLons(firstIdx);
uniqueLats = allLats(firstIdx);

shapefileName = 'Zhejiang_boundary.shp';
provinceData = []; outer_boundary_ps = [];
if exist(shapefileName, 'file')
    try
        disp(['load boundary: ' shapefileName]);
        provinceData = shaperead(shapefileName);
        if exist('polyshape', 'file')
            all_polyshapes = arrayfun(@(s) polyshape(s.X, s.Y, 'Simplify', false), provinceData);
            outer_boundary_ps = union(all_polyshapes);
        else
            warning('polyshape can not be used');
        end
    catch ME_shp
        disp(['load ' shapefileName ' error: ' ME_shp.message]);
    end
else
    disp(['error ' shapefileName 'can not do']);
end
if ~isempty(outer_boundary_ps)
    in_zhejiang_idx = isinterior(outer_boundary_ps, uniqueLons, uniqueLats);
    uniqueLons_filtered = uniqueLons(in_zhejiang_idx);
    uniqueLats_filtered = uniqueLats(in_zhejiang_idx);
    uniqueNames_filtered = uniqueNames(in_zhejiang_idx);
else
    uniqueLons_filtered = uniqueLons;
    uniqueLats_filtered = uniqueLats;
    uniqueNames_filtered = uniqueNames;
end
isValidation = ismember(string(uniqueNames_filtered), specificSiteNames);
sitesForRedStars_Lon = uniqueLons_filtered(~isValidation);
sitesForRedStars_Lat = uniqueLats_filtered(~isValidation);
sitesForBlueDiamonds_Lon = uniqueLons_filtered(isValidation);
sitesForBlueDiamonds_Lat = uniqueLats_filtered(isValidation);
figWidth_cm = 12.9;
plot_aspect_ratio = diff(mapDisplayLatLim) / diff(mapDisplayLonLim);
figHeight_cm = figWidth_cm * plot_aspect_ratio;
axisLabelFontSize = 13;
tickLabelFontSize = 11; 
siteNameFontSize = 9;
legendFontSize = 10;
axesInnerPosition = [0.1, 0.1, 0.88, 0.88]; 
set(0, 'Units', 'centimeters');
screenSize = get(0, 'ScreenSize');
left_pos = (screenSize(3) - figWidth_cm) / 2;
bottom_pos = (screenSize(4) - figHeight_cm) / 2;
fig = figure('Name', 'GNSS Stations Map (Final Style)', ...
    'Color', 'w', ...
    'Units', 'centimeters', ...
    'Position', [left_pos, bottom_pos, figWidth_cm, figHeight_cm], ...
    'Renderer', 'painters');
ax = gca;
hold on;
set(ax, 'Color', 'w');
ax.FontSize = tickLabelFontSize;
blueBorderLon = [118, 124]; blueBorderLat = [27, 31.5];
x_major_ticks = 117:1:124; y_major_ticks = 27:1:32;
x_minor_ticks = 117:0.5:124; y_minor_ticks = 26.5:0.5:32;
grayColor = [0.8, 0.8, 0.8]; blueColor = 'b';
for i = 1:length(x_minor_ticks), line(ax, [x_minor_ticks(i), x_minor_ticks(i)], mapDisplayLatLim, 'Color', grayColor, 'LineWidth', 0.5); end
for i = 1:length(y_minor_ticks), line(ax, mapDisplayLonLim, [y_minor_ticks(i), y_minor_ticks(i)], 'Color', grayColor, 'LineWidth', 0.5); end
for i = 1:length(x_minor_ticks), line(ax, [x_minor_ticks(i), x_minor_ticks(i)], blueBorderLat, 'Color', blueColor, 'LineWidth', 0.8); end
for i = 1:length(y_minor_ticks), line(ax, blueBorderLon, [y_minor_ticks(i), y_minor_ticks(i)], 'Color', blueColor, 'LineWidth', 0.8); end
if ~isempty(provinceData)
    geoshow(ax, provinceData, 'DisplayType', 'polygon', 'EdgeColor', [0.6 0.6 0.6], 'LineStyle', '--', 'FaceColor', 'none');
    if ~isempty(outer_boundary_ps), plot(outer_boundary_ps, 'FaceColor', 'none', 'EdgeColor', 'k', 'LineWidth', 0.8, 'HandleVisibility', 'off'); end
end
if ~isempty(sitesForRedStars_Lat), h_gnss = scatter(ax, sitesForRedStars_Lon, sitesForRedStars_Lat, 85, 'p', 'MarkerEdgeColor', 'none', 'MarkerFaceColor','r', 'LineWidth', 0.5, 'DisplayName', 'GNSS stations'); end
if ~isempty(sitesForBlueDiamonds_Lat), h_val = scatter(ax, sitesForBlueDiamonds_Lon, sitesForBlueDiamonds_Lat, 50, 'd', 'MarkerEdgeColor', 'none', 'MarkerFaceColor','b', 'LineWidth', 0.5, 'DisplayName', 'Validation stations'); end
disp('Adding name labels to all stations within the province...');
textOffset = 0.05;
for i = 1:length(uniqueNames_filtered)
    lon = uniqueLons_filtered(i); lat = uniqueLats_filtered(i); name = uniqueNames_filtered{i};
    quadrant = mod(i, 4);
    switch quadrant
        case 0, ha = 'left'; va = 'bottom';
        case 1, ha = 'right'; va = 'bottom';
        case 2, ha = 'right'; va = 'top';
        case 3, ha = 'left'; va = 'top';
    end
    if isValidation(i), labelColor = 'b'; else, labelColor = 'r'; end
    text(lon + textOffset * (2*strcmp(ha,'left')-1), lat + textOffset * (2*strcmp(va,'bottom')-1), name, ...
         'HorizontalAlignment', ha, 'VerticalAlignment', va, ...
         'FontSize', siteNameFontSize, 'Color', labelColor, 'FontWeight', 'normal');
end

rectangle(ax, 'Position', [blueBorderLon(1), blueBorderLat(1), diff(blueBorderLon), diff(blueBorderLat)], 'EdgeColor', 'b', 'LineWidth', 0.5, 'LineStyle', '-');
axis(ax, [mapDisplayLonLim mapDisplayLatLim]);
ax.XTick = x_major_ticks;
ax.YTick = y_major_ticks;
box(ax, 'on');
ax.Layer = 'top';
xlabel(ax, 'Longitude (°E)', 'FontSize', axisLabelFontSize);
ylabel(ax, 'Latitude (°N)', 'FontSize', axisLabelFontSize);
legendHandles = []; legendTexts = {};
if exist('h_gnss', 'var') && isgraphics(h_gnss(1)), legendHandles(end+1) = h_gnss(1); legendTexts{end+1} = get(h_gnss(1), 'DisplayName'); end
if exist('h_val', 'var') && isgraphics(h_val(1)), legendHandles(end+1) = h_val(1); legendTexts{end+1} = get(h_val(1), 'DisplayName'); end
if ~isempty(legendHandles), legend(ax, legendHandles, legendTexts, 'Location', 'northeast', 'FontSize', legendFontSize); end

hold off;
axis(ax, 'equal'); 
axis(ax, [mapDisplayLonLim mapDisplayLatLim]); 
set(ax, 'Position', axesInnerPosition);

fontName = 'Arial';
set(findall(fig, '-property', 'FontName'), 'FontName', fontName);
set(findall(fig, 'Type', 'text'), 'Interpreter', 'none');
set(ax, 'TickLabelInterpreter', 'none');
if ~isempty(legendHandles)
    lgd = legend(ax);
    if isgraphics(lgd)
        lgd.Interpreter = 'none';
    end
end
scriptFullPath = mfilename('fullpath');
if isempty(scriptFullPath)
    outputDir = pwd;
    outputBaseName = 'GNSS_stations_map';
else
    outputDir = fileparts(scriptFullPath);
    [~, outputBaseName] = fileparts(scriptFullPath);
end
pdfFile = fullfile(outputDir, [outputBaseName '_output.pdf']);
exportgraphics(fig, pdfFile, ...
    'ContentType', 'vector', ...
    'BackgroundColor', 'white');
