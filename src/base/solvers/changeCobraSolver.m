function solverOK = changeCobraSolver(solverName, solverType, printLevel, unchecked)
% Changes the Cobra Toolbox optimization solver(s)
%
% USAGE:
%
%    solverOK = changeCobraSolver(solverName, solverType, printLevel, unchecked)
%
% INPUTS:
%    solverName:    Solver name
%    solverType:    Solver type, 'LP', 'MILP', 'QP', 'MIQP' (opt, default
%                   'LP', 'all').  'all' attempts to change all applicable
%                   solvers to solverName.  This is purely a shorthand
%                   convenience.
%    printLevel:    if 0, warnings and errors are silenced and if > 0, they are
%                   thrown. (default: 1)
%
% OPTIONAL INPUT:
%    unchecked:     default = 0, if exists `solverType` is checked and `solverName` is assigned to a local variable
%
% OUTPUT:
%     solverOK:     true if solver can be accessed, false if not
%
% Currently allowed LP solvers:
%
%   - fully supported solvers
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab `cplex.m`. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     dqqMinos        DQQ solver
%     glpk            GLPK solver with Matlab mex interface (glpkmex)
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     matlab          MATLAB's linprog function
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     pdco            PDCO solver
%     quadMinos       quad LP solver
%     tomlab_cplex    CPLEX accessed through Tomlab environment (default)
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     lindo_new       Lindo API > v2.0
%     lindo_legacy    Lindo API < v2.0
%     lp_solve        lp_solve with Matlab API
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%     ============    ============================================================
%
% Currently allowed MILP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     glpk            glpk MILP solver with Matlab mex interface (glpkmex)
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     tomlab_cplex    CPLEX MILP solver accessed through Tomlab environment
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper
%                     Lower level calls with installed mex files are possible
%                     but best avoided for all solvers
%     ============    ============================================================
%
% Currently allowed QP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     mosek           Mosek LP solver with Matlab API (using linprog.m from Mosek)
%     pdco            PDCO solver
%     tomlab_cplex    CPLEX QP solver accessed through Tomlab environment
%     ============    ============================================================
%
%   * experimental support:
%
%     ============    ============================================================
%     qpng            qpng QP solver with Matlab mex interface (in glpkmex
%                     package, only limited support for small problems)
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     opti            CLP(recommended), CSDP, DSDP, OOQP and SCIP(recommended)
%                     solver installed and called with OPTI TB wrapper.
%                     Lower level calls with installed mex files are possible
%     ============    ============================================================
%
% Currently allowed MIQP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     cplex_direct    CPLEX accessed directly through Tomlab cplex.m. This gives
%                     the user more control of solver parameters. e.g.
%                     minimising the Euclidean norm of the internal flux to
%                     get rid of net flux around loops
%     gurobi          Gurobi solver
%     ibm_cplex       The IBM API for CPLEX using the CPLEX class
%     tomlab_cplex    CPLEX MIQP solver accessed through Tomlab environment
%     ============    ============================================================
%
%   * legacy solvers:
%
%     ============    ============================================================
%     gurobi_mex      Gurobi accessed through Matlab mex interface (Gurobi mex)
%     ============    ============================================================
%
% Currently allowed NLP solvers:
%
%   * fully supported solvers:
%
%     ============    ============================================================
%     matlab          MATLAB's fmincon.m
%     ============    ============================================================
%
%   * experimental support:
%
%     ============    ============================================================
%     tomlab_snopt    SNOPT solver accessed through Tomlab environment
%     ============    ============================================================
%
% NOTE:
%
%    It is a good idea to put this function call into your `startup.m` file
%    (usually matlabinstall/toolboxes/local/startup.m)
%
% .. Author: -  Original file: Markus Herrgard, 1/19/07

global SOLVERS;
global CBTDIR;
global OPT_PROB_TYPES;
global CBT_LP_SOLVER;
global CBT_MILP_SOLVER;
global CBT_QP_SOLVER;
global CBT_MIQP_SOLVER;
global CBT_NLP_SOLVER;
global ENV_VARS;
global TOMLAB_PATH;
global MOSEK_PATH;
global GUROBI_PATH;
global MINOS_PATH;
global ILOG_CPLEX_PATH;

if nargin < 3
    printLevel = 1;
end

if ~exist('unchecked' , 'var')
    unchecked = 0;
end

if unchecked
    switch solverType
        case 'LP'
            CBT_LP_SOLVER = solverName;
        case 'QP'
            CBT_QP_SOLVER = solverName;
        case 'MILP'
            CBT_MILP_SOLVER = solverName;
        case 'NLP'
            CBT_NLP_SOLVER = solverName;
        case 'MIQP'
            CBT_MIQP_SOLVER = solverName;
    end
    return
end

if isempty(SOLVERS) || isempty(OPT_PROB_TYPES)
    ENV_VARS.printLevel = false;
    initCobraToolbox;
    ENV_VARS.printLevel = true;
end

% configure the environment variables
configEnvVars();

% Print out all solvers defined in global variables CBT_*_SOLVER
if nargin < 1
    definedSolvers = [CBT_LP_SOLVER, CBT_MILP_SOLVER, CBT_QP_SOLVER, CBT_MIQP_SOLVER, CBT_NLP_SOLVER];
    if isempty(definedSolvers)
        fprintf('No solvers are defined!\n');
    else
        fprintf('Defined solvers are:\n');
        for i = 1:length(OPT_PROB_TYPES)
            varName = horzcat(['CBT_', OPT_PROB_TYPES{i}, '_SOLVER']);
            if ~isempty(eval(varName))
                fprintf('    %s: %s\n', varName, eval(varName));
            end
        end
    end
    return;
end

% legacy support for other versions of gurobi
if strcmpi(solverName, 'gurobi') || strcmpi(solverName, 'gurobi6') ||  strcmpi(solverName, 'gurobi7')
    solverName = 'gurobi';
end

% check if the global environment variable is properly set
if ~ENV_VARS.STATUS

    if isempty(GUROBI_PATH) || isempty(ILOG_CPLEX_PATH) || isempty(TOMLAB_PATH) || isempty(MOSEK_PATH)
        switch solverName
            case 'gurobi'
                tmpVar = 'GUROBI_PATH';
            case 'ibm_cplex'
                tmpVar = 'ILOG_CPLEX_PATH';
            case {'tomlab_cplex', 'cplex_direct'}
                tmpVar = 'TOMLAB_PATH';
            case 'mosek'
                tmpVar = 'MOSEK_PATH';
        end
        if printLevel > 0 && (strcmpi(solverName, 'gurobi') || strcmpi(solverName, 'ibm_cplex') || strcmpi(solverName, 'tomlab_cplex') || strcmpi(solverName, 'cplex_direct') || strcmpi(solverName, 'mosek'))
            error(['The global variable `', tmpVar, '` is not set. Please follow ', hyperlink('https://opencobra.github.io/cobratoolbox/docs/solvers.html', 'these instructions', 'the instructions on '), ' to set the environment variables properly.']);
        end
    end
end

% set path to MINOS and DQQ
MINOS_PATH = [CBTDIR filesep 'binary' filesep computer('arch') filesep 'bin' filesep 'minos' filesep];

% legacy support for MPS (will be removed in future release)
if nargin > 0 && strcmpi(solverName, 'mps')
    fprintf(' > The interface to ''mps'' from ''changeCobraSolver()'' is no longer supported.\n');
    error(' -> Use >> writeCbModel(model, \''mps\''); instead.)');
end

if nargin < 2
    solverType = 'LP';
else
    solverType = upper(solverType);
end

% print an error message if the solver is not supported
supportedSolversNames = fieldnames(SOLVERS);
if ~any(strcmp(supportedSolversNames, solverName))
    error('The solver %s is not supported. Please run >> initCobraToolbox to obtain a table with available solvers.', solverName);
end

% Attempt to set the user provided solver for all optimization problem types
if strcmpi(solverType, 'all')    
    solvedProblems = SOLVERS.(solverName).type;    
    for i = 1:length(solvedProblems)
        changeCobraSolver(solverName, solvedProblems{i}, printLevel);
        if printLevel > 0
            fprintf([' > Solver for ', solvedProblems{i}, ' problems has been set to ', solverName, '.\n']);
        end
    end
    notsupportedProblems = setdiff(OPT_PROB_TYPES,solvedProblems);
    for i = 1:length(notsupportedProblems)
        solverUsed = eval(['CBT_' notsupportedProblems{i} '_SOLVER']);
        if isempty(solverUsed)
            infoString = 'No solver set for this problemtype';
        else
            infoString = sprintf('Currently used: %s',solverUsed);
        end
        if printLevel > 0
            fprintf(' > Solver %s not supported for problems of type %s. %s \n', solverName, notsupportedProblems{i},infoString); 
        end
    end
    return
end

% check if the given solver is able to solve the given problem type.
solverOK = false;
if isempty(strmatch(solverType, OPT_PROB_TYPES))
    if printLevel > 0
        error('%s problems cannot be solved in The COBRA Toolbox', solverType);
    else
        return
    end
end

% check if the given solver is able to solve the given problem type.
if isempty(strmatch(solverType, SOLVERS.(solverName).type))
    if printLevel > 0
        error('Solver %s cannot solve %s problems', solverName, solverType);
    else
        return
    end
end

% add the solver path for GUROBI, MOSEK or CPLEX
if (~isempty(strfind(solverName, 'tomlab')) || ~isempty(strfind(solverName, 'cplex_direct'))) && ~isempty(TOMLAB_PATH)
    TOMLAB_PATH = strrep(TOMLAB_PATH, '~', getenv('HOME'));
    addpath(genpath(strrep(TOMLAB_PATH, '\\', '\')));
    if printLevel > 0
        fprintf('\n > Tomlab interface added to MATLAB path.\n');
    end
end

if  ~isempty(strfind(solverName, 'gurobi')) && ~isempty(GUROBI_PATH)
    % add the solver path
    GUROBI_PATH = strrep(GUROBI_PATH, '~', getenv('HOME'));
    addpath(strrep(GUROBI_PATH, '\\', '\'));
    if printLevel > 0
        fprintf('\n > Gurobi interface added to MATLAB path.\n');
    end
end

if  ~isempty(strfind(solverName, 'ibm_cplex')) && ~isempty(ILOG_CPLEX_PATH)
    % add the solver path
    ILOG_CPLEX_PATH = strrep(ILOG_CPLEX_PATH, '~', getenv('HOME'));
    addpath(strrep(ILOG_CPLEX_PATH, '\\', '\'));
    if printLevel > 0
        fprintf('\n > IBM ILOG CPLEX interface added to MATLAB path.\n');
    end
end

if  ~isempty(strfind(solverName, 'mosek')) && ~isempty(MOSEK_PATH)
    MOSEK_PATH = strrep(MOSEK_PATH, '~', getenv('HOME'));
    addpath(genpath(strrep(MOSEK_PATH, '\\', '\')));
    if printLevel > 0
        fprintf('\n > MOSEK interface added to MATLAB path.\n');
    end
end

solverOK = false;

switch solverName
    case {'lindo_old', 'lindo_legacy'}
        solverOK = checkSolverInstallationFile(solverName, 'mxlindo', printLevel);
    case 'glpk'
        solverOK = checkSolverInstallationFile(solverName, 'glpkmex', printLevel);
    case 'mosek'
        solverOK = checkSolverInstallationFile(solverName, 'mosekopt', printLevel);
    case {'tomlab_cplex', 'tomlab_snopt'}
        solverOK = checkSolverInstallationFile(solverName, 'tomRun', printLevel);
    case 'cplex_direct'
        if ~verLessThan('matlab', '8.4')
            if printLevel > 0
                fprintf(' > The cplex_direct is incompatible with this version of MATLAB, please downgrade or change solver.\n');
            end
        else
            solverOK = checkSolverInstallationFile(solverName, 'tomRun', printLevel);
        end
    case 'ibm_cplex'
        if ~verLessThan('matlab', '9') && isempty(strfind(ILOG_CPLEX_PATH, '1271'))  % 2016b
            if printLevel > 0
                fprintf(' > ibm_cplex (IBM ILOG CPLEX) is incompatible with this version of MATLAB, please downgrade or change solver.\n');
            end
        else
            try
                ILOGcplex = Cplex('fba');  % Initialize the CPLEX object
                solverOK = true;
            catch ME
                solverOK = false;
            end
        end
        if verLessThan('matlab', '9') && ~verLessThan('matlab', '8.6')  % >2015b
            warning('off', 'MATLAB:lang:badlyScopedReturnValue');  % take out warning message
        end
    case {'lp_solve', 'qpng', 'pdco', 'gurobi_mex'}
        solverOK = checkSolverInstallationFile(solverName, solverName, printLevel);
    case 'gurobi'
        solverOK = checkSolverInstallationFile(solverName, 'gurobi.m', printLevel);
    case {'quadMinos', 'dqqMinos'}
        if isunix
            [stat, res] = system('which csh');
            if ~isempty(res) && stat == 0
                if strcmp(solverName, 'dqqMinos')
                    solverOK = checkSolverInstallationFile(solverName, 'run1DQQ', printLevel);
                elseif strcmp(solverName, 'quadMinos')
                    solverOK = checkSolverInstallationFile(solverName, 'minos', printLevel);
                end
            else
                solverOK = false;
                if printLevel > 0
                    error(['You must have `csh` installed in order to use `', solverName, '`.']);
                end
            end
        end
    case 'opti'
        if verLessThan('matlab', '8.4')
            optiSolvers = {'CLP', 'CSDP', 'DSDP', 'OOQP', 'SCIP'};
            if ~isempty(which('checkSolver'))
                availableSolvers = cellfun(@(x)checkSolver(lower(x)), optiSolvers);
                fprintf('OPTI solvers installed currently: ');
                fprintf(char(allLPsolvers(logical(availableSolvers))));
                if ~any(logical(availableSolvers))
                    return;
                end
            end
        end
    case 'matlab'
        solverOK = true;
    otherwise
        error(['Solver ' solverName ' not supported by The COBRA Toolbox.']);
end

% set solver related global variables
if solverOK
    eval(['CBT_', solverType, '_SOLVER = solverName;']);
end
end

function solverOK = checkSolverInstallationFile(solverName, fileName, printLevel)
% Check solver installation by existence of a file in the Matlab path.
%
% Usage:
%     solverOK = checkSolverInstallation(solverName, fileName)
%
% Inputs:
%     solverName: string with the name of the solver
%     fileName:   string with the name of the file to look for
%
% Output:
%     solverOK: true if filename exists, false otherwise.
%

    solverOK = false;
    if exist(fileName, 'file') >= 2
        solverOK = true;
    elseif printLevel > 0
        error(['Solver ', solverName, ' is not installed. Please follow ', hyperlink('https://opencobra.github.io/cobratoolbox/docs/solvers.html', 'these instructions', 'the instructions on '), ' in order to install the solver properly.'])
    end
end
