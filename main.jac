"""TaskFlow - A multi-user todo app with AI meal planning."""

cl {
    import from frontend { app as ClientApp }

    def:pub app -> any {
        return
            <ClientApp />;
    }
}

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="gemini/gemini-2.5-flash");

# --- AI Types ---

enum Category { WORK, PERSONAL, SHOPPING, HEALTH, OTHER }

enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, CLOVE, BUNCH }

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "True if this ingredient is high in carbohydrates";

"""Categorize a todo based on its title."""
def categorize(title: str) -> Category by llm();

"""Generate a shopping list of ingredients needed for a described meal."""
def generate_ingredients(meal_description: str) -> list[Ingredient] by llm();

# --- Data Nodes ---

node Todo {
    has id: str,
        title: str,
        completed: bool = False,
        category: str = "other";
}

node MealIngredient {
    has name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

# --- Todo Walkers ---

walker:priv AddTodo {
    has title: str;

    can create with Root entry {
        category = str(categorize(self.title)).split(".")[-1].lower();
        new_todo = here ++> Todo(
            id=str(uuid4()),
            title=self.title,
            category=category
        );
        report {
            "id": new_todo[0].id,
            "title": new_todo[0].title,
            "completed": new_todo[0].completed,
            "category": new_todo[0].category
        };
    }
}

walker:priv ListTodos {
    has todos: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with Todo entry {
        self.todos.append({
            "id": here.id,
            "title": here.title,
            "completed": here.completed,
            "category": here.category
        });
    }

    can report_all with Root exit {
        report self.todos;
    }
}

walker:priv ToggleTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can toggle with Todo entry {
        if here.id == self.todo_id {
            here.completed = not here.completed;
            report {
                "id": here.id,
                "completed": here.completed
            };
        }
    }
}

walker:priv DeleteTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can delete with Todo entry {
        if here.id == self.todo_id {
            del here;
            report {"deleted": self.todo_id};
        }
    }
}

# --- Meal Planner Walkers ---

walker:priv GenerateShoppingList {
    has meal_description: str;

    can generate with Root entry {
        # First clear old ingredients
        visit [-->];
        # Then generate new ones
        ingredients = generate_ingredients(self.meal_description);
        result: list = [];
        for ing in ingredients {
            ing_data = {
                "name": ing.name,
                "quantity": ing.quantity,
                "unit": str(ing.unit).split(".")[-1].lower(),
                "cost": ing.cost,
                "carby": ing.carby
            };
            here ++> MealIngredient(
                name=ing_data["name"],
                quantity=ing_data["quantity"],
                unit=ing_data["unit"],
                cost=ing_data["cost"],
                carby=ing_data["carby"]
            );
            result.append(ing_data);
        }
        report result;
    }

    can clear_old with MealIngredient entry {
        del here;
    }
}

walker:priv ListMealPlan {
    has ingredients: list = [];

    can collect with Root entry {
        visit [-->];
    }

    can gather with MealIngredient entry {
        self.ingredients.append({
            "name": here.name,
            "quantity": here.quantity,
            "unit": here.unit,
            "cost": here.cost,
            "carby": here.carby
        });
    }

    can report_all with Root exit {
        report self.ingredients;
    }
}

walker:priv ClearMealPlan {
    can collect with Root entry {
        visit [-->];
    }

    can clear with MealIngredient entry {
        del here;
        report {"cleared": True};
    }
}