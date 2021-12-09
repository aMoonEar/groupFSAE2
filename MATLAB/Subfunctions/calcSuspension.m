%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function: ___
%
%   Parameters: driverMass (kg)
%   
%   Outputs: totalMass (kg)
%
%   ___.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [] = calcSuspension(...
    FxFront,...
    FxRear,...
    FyFront,...
    FyRear,...
    FzFront,...
    FzRear)
    

    

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function: ___
%
%   Parameters: driverMass (kg)
%   
%   Outputs: totalMass (kg)
%
%   ___.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outputForces] = calcFrontMatrix(...
    distanceToWheelCenter,...
    forceX,...
    forceY,...
    forceZ)
    
    % Calculate the moment on each axis
    momentX = forceZ * distanceToWheelCenter*-1; % Nm
    momentY = forceY *30;
    momentZ = forceX * 1000; % Nm

    % 6 x 6 of unit vectors and cross product of the six suspension members
    matrixSuspension = [0.828704311    0.808473745 0.832246334 0.800323279 0.999991335 0.356279976;
        0.020201131	0.021243238	0.15046778	0.144688074	0.00411985	-0.934379248;
        0.559321981	-0.58814873	0.533596746	-0.581848786	0.000597535	0;
        -63.93050247    67.22539987	60.99010806	-66.50531626	0.286323273	0;
        -16.77965944    17.64446191	-16.00790238	17.45546358	77.36543396	0;
        94.11486886 91.7712519  -99.63978934    -95.81759304    54.24477574	140.6270801];
    
    % 1 x 6 matrix of input forces and moments
    matrixInput = [forceX;
        forceY;
        forceZ;
        momentX;
        momentY;
        momentZ];
    
    % Calculate the division of matrix A/B to determine the forces in
    % compression and tension 
    % (negative represents compress, positive tension)
    outputForces = matrixSuspension\matrixInput; % N
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Function: ___
%
%   Parameters: driverMass (kg)
%   
%   Outputs: totalMass (kg)
%
%   ___.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [outputForces] = calcRearMatrix(...
    distanceToWheelCenter,...
    forceX,...
    forceY,...
    forceZ)

    % Calculate the moment on each axis
    % Note: there is no moment produced in the y axis in the rear
    momentX = forceZ * distanceToWheelCenter*-1; % Nm
    momentZ = forceX * 1000; % Nm
    
    % 6 x 6 of unit vectors and cross product of the six suspension members
    matrixSuspension = [0.866866558	0.864733903	0.853901901	0.853131429	0.410587839;
        0.02281423  0.022758103	0.164948356	0.164799524	-0.901009187;
        0.498017953 -0.501714407	0.493602657	-0.494982708 -0.140000253;
        -56.92345208	57.34595669	56.41878367	-56.57652352 29.00168725;
        98.39842064 98.15634201 -102.549438	-102.4569081 123.131826];

    % 1 x 6 matrix of input forces and moments
    matrixInput = [forceX;
        forceY;
        forceZ;
        momentX;
        momentZ];
    
    % Calculate the division of matrix A/B to determine the forces in
    % compression and tension 
    % (negative represents compress, positive tension)
    outputForces = matrixSuspension\matrixInput; % N

end


function [safetyFactorCriticalLoad, safetyFactorAxialStress] = calcStress(...
    inputForces,...
    front,...
    innerDiameter,...
    outerDiameter)

    % find the maximum and minimum of the inputs to determine the critical
    % stresses under tension and compression
    [maximumForce] = max(inputForces); % N
    [minimumForce, minimumIndex] = min(inputForces); % N
    
    if (front)
        % Order of geometry is
        % AC, AB, DF, DE, IJ, GH
        frontLengthGeometry = [393.0473096, 373.7660029, 393.7055494, 377.8473123, 317.9727553, 575.5585875]; % mm
        minimumLength = frontLengthGeometry(minimumIndex); % mm
    else
        % Order of the geometry is
        % KM, KL, NP, NO, QR
        rearLengthGeometry = [269.568595, 270.23342, 273.661412, 273.9085585, 368.6421899]; % mm
        minimumLength = rearLengthGeometry(minimumIndex); % mm
    end
    
    elasticModulus = 205000; % MPa
    yieldStrength = 435; % MPa
    columnEffectiveLengthFactor = 1;
    momentOfInertia = (pi/4)*((outerDiameter/2)^4-(innerDiameter/2)^4); % mm^4
    crossSectionArea = (pi*(outerDiameter/2)^2)-(pi*(innerDiameter/2)^2); % mm^2
    
    % Calculate the critical load & safety factor
    criticalLoad =((pi^2*elasticModulus*momentOfInertia)/((columnEffectiveLengthFactor*minimumLength)^2)); % N
    safetyFactorCriticalLoad = criticalLoad/minimumForce*-1;
    
    % Calculate the axial stress and safety factor
    axialStress = maximumForce/crossSectionArea; % MPa
    safetyFactorAxialStress = yieldStrength/axialStress;

end