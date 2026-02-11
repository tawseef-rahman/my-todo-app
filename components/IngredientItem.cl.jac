"""Ingredient item component for the shopping list."""

def:pub IngredientItem(ingredient: dict) -> any {
    return
        <div className="ingredient-item">
            <div className="ingredient-info">
                <span className="ingredient-name">{ingredient.name}</span>
                <span className="ingredient-qty">
                    {ingredient.quantity} {ingredient.unit}
                </span>
            </div>
            <div className="ingredient-meta">
                {(
                    <span className="carb-badge">Carbs</span>
                ) if ingredient.carby else None}
                <span className="cost-label">${ingredient.cost.toFixed(2)}</span>
            </div>
        </div>;
}