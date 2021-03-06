function restrictedModels = restrictModelsToFields(models, fieldNames)
% Removes all fields not given as fieldnames from the models
%
% USAGE:
%
%    restrictedModels = restrictModelsToFields(models, fieldNames)
%
% INPUT:
%    models:           A Cell array of model structs (or single model
%                      struct that has all fieldNames provided.
%    fieldNames:       Names of the fields the models will be restricted
%                      to.
%
% OUTPUT:
%    restrictedModels:    The models with the non names fields removed, or a single struct if its just one model.
%
% .. Author: - Thomas Pfau May 2017


structin = false;
if isstruct(models)
    models = { models};
    structin = true;
end
restrictedModels = cell(size(models));
for i = 1: numel(models)
    newModel = struct();
    cmodel = models{i};
    for f = 1:numel(fieldNames)
        newModel.(fieldNames{f}) = cmodel.(fieldNames{f});
    end
    restrictedModels{i} = newModel;
end

if structin
    restrictedModels = restrictedModels{1};
end
