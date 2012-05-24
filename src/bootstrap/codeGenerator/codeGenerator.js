var cg = require('../../lib/codeGenerator');

exports.codeGenerator = function () {
  codegen = {};
  
  codegen.basicExpression = require('./basicExpression');
  codegen.variable = cg.variable;
  codegen.selfExpression = cg.selfExpression;
  codegen.statements = cg.statements;
  codegen.block = cg.block;
  codegen.parameters = cg.parameters;
  codegen.identifier = cg.identifier;
  codegen.integer = cg.integer;
  codegen.float = cg.float;
  codegen.normaliseString = cg.normaliseString;
  codegen.unindent = cg.unindent;
  codegen.normaliseInterpolatedString = cg.normaliseInterpolatedString;
  codegen.string = cg.string;
  codegen.interpolatedString = cg.interpolatedString;
  codegen.normaliseRegExp = cg.normaliseRegExp;
  codegen.regExp = cg.regExp;
  codegen.parseRegExp = cg.parseRegExp;
  codegen.module = cg.module;
  codegen.interpolation = cg.interpolation;
  codegen.list = cg.list;
  codegen.normaliseArguments = cg.normaliseArguments;
  codegen.argumentList = cg.argumentList;
  codegen.subExpression = cg.subExpression;
  codegen.fieldReference = cg.fieldReference;
  codegen.hash = cg.hash;
  codegen.asyncArgument = cg.asyncArgument;
  codegen.complexExpression = require('./complexExpression');
  codegen.operatorExpression = require('./operatorExpression');
  codegen.newUnaryOperatorExpression = require('./unaryOperatorExpression').newUnaryOperatorExpression;
  codegen.operator = cg.operator;
  codegen.splat = cg.splat;
  codegen.javascript = cg.javascript;
  codegen.hashEntry = cg.hashEntry;
  codegen.concatName = cg.concatName;
  codegen.parseSplatParameters = cg.parseSplatParameters;
  codegen.collapse = cg.collapse;
  codegen.definition = cg.definition;
  codegen.functionCall = cg.functionCall;
  codegen.scope = cg.scope;
  codegen.Scope = cg.Scope;
  codegen.MacroDirectory = cg.MacroDirectory;
  codegen.boolean = cg.boolean;
  codegen.tryStatement = cg.tryStatement;
  codegen.ifCases = cg.ifCases;
  codegen.continueStatement = cg.continueStatement;
  codegen.breakStatement = cg.breakStatement;
  codegen.throwStatement = cg.throwStatement;
  codegen.returnStatement = cg.returnStatement;
  codegen.methodCall = cg.methodCall;
  codegen.indexer = cg.indexer;
  codegen.whileStatement = cg.whileStatement;
  codegen.forStatement = cg.forStatement;
  codegen.forIn = cg.forIn;
  codegen.forEach = cg.forEach;
  codegen.newOperator = cg.newOperator;
  codegen.loc = loc;
  codegen.term = cg.term;
  codegen.errors = require('./errors').errors(codegen);
  codegen.macros = require('./macros').macros(codegen);
  
  return codegen;
};

var loc = function (term, location) {
  var loc = {
    firstLine: location.first_line,
    lastLine: location.last_line,
    firstColumn: location.first_column,
    lastColumn: location.last_column
  };

  term.location = function () {
    return loc;
  };
  
  return term;
};
