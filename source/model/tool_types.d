module model.tool_types;

public import model.entities.condition : Condition;

struct ExpressionError
{
    string expression;
    string error;
}

struct QuickAddConditionsResult
{
    Condition[] conditions;
    ExpressionError[] errors;
}
