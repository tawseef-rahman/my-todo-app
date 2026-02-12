# my-todo-app

Name: Tawseef Rahman

UMID: 22516081

A Jac client-side application with React support.

## Project Structure

```
my-todo-app/
├── jac.toml                    # Project configuration
├── main.jac                    # Main application entry
├── components/                 # Reusable components
│   └── AuthForm.cl.jac         # Jac component - for a login instance
│   └── Button.cl.jac           # Jac component - for a button
│   └── IngredientItem.cl.jac   # Jac component - for an ingredient item
│   └── TodoItem.cl.jac         # Jac component - for a todo item
├── assets/                     # Static assets (images, fonts, etc.)
├── frontend.cl.jac             # Setup of frontend
├── frontend.impl.jac           # Implementation of frontend
├── style.css                   # Styling of application
└── build/                      # Build output (generated)
```

## Getting Started

### 1: Clone the repository:

```bash
git clone https://github.com/tawseef-rahman/my-todo-app.git
```

### 2: Create a virtual environment:

```bash
python -m venv jac-env
```

OR (depending on what version of Python you have installled)

```bash
python3 -m venv jac-env
```

### 3: Activate the virtual environment:

For Linux/Mac:

```bash
source jac-env/bin/activate
```

For Windows:

```bash
jac-env\Scripts\activate
```

### 4: Install Jaseci:

```bash
pip install jaseci
```

### 5: Start the development server:

```bash
jac start main.jac
```

## Extra Feature

For this extra credit assignment, I added the capability of the user to add a due date for a todo item (when creating a new item and for existing items) by selecting a date from a calendar.

The code necessary to add this capability is reflected in the code snippets of the following files (more details can be found in this [Git commit](https://github.com/tawseef-rahman/my-todo-app/commit/d817df2afa94cc3322ec6520afe5cc40d2fdc10d)):

`components/TodoItem.cl.jac`

```
"""Todo item component."""

def:pub TodoItem(todo: dict, onToggle: any, onDelete: any) -> any {
def:pub TodoItem(todo: dict, onToggle: any, onDelete: any, onUpdateDueDate: any) -> any {
    return
        <div className="todo-item">
            <input
@@ -12,6 +12,12 @@ def:pub TodoItem(todo: dict, onToggle: any, onDelete: any) -> any {
            <span className={("todo-title-completed" if todo.completed else "todo-title")}>
                {todo.title}
            </span>
            <input
                type="date"
                value={todo.due_date}
                onChange={lambda e : any -> None { onUpdateDueDate(todo.id, e.target.value); }}
                className="todo-date"
            />
            {(
                <span className="category-badge">{todo.category}</span>
            ) if todo.category and todo.category != "other" else None}
```

`frontend.cl.jac`

```
@@ -10,7 +10,8 @@ import from .components.IngredientItem { IngredientItem }

sv import from main {
    AddTodo, ListTodos, ToggleTodo, DeleteTodo,
    GenerateShoppingList, ListMealPlan, ClearMealPlan
    GenerateShoppingList, ListMealPlan, ClearMealPlan,
    UpdateDueDate
}

def:pub app -> any {
@@ -26,7 +27,8 @@ def:pub app -> any {
        todosLoading: bool = True,
        mealInput: str = "",
        ingredients: list = [],
        ingredientsLoading: bool = False;
        ingredientsLoading: bool = False,
        dueDate: str = "";

    can with entry {
        isLoggedIn = jacIsLoggedIn();
@@ -55,6 +57,7 @@ def:pub app -> any {
    async def clearIngredients -> None;
    def handleMealKeyPress(e: any) -> None;
    def getIngredientsTotal -> float;
    async def updateDueDate(todoId: str, date: str) -> None;

    if checkingAuth {
        return
@@ -95,6 +98,13 @@ def:pub app -> any {
                                        placeholder="What needs to be done?"
                                        className="todo-input"
                                    />
                                    <input
                                        type="date"
                                        value={dueDate}
                                        onChange={lambda e : any -> None { dueDate = e.target.value; }}
                                        className="todo-input"
                                        style={{"maxwidth": "160px"}}
                                    />
                                    <button
                                        onClick={lambda -> None { addTodo(); }}
                                        className="btn-add"
@@ -120,6 +130,7 @@ def:pub app -> any {
                                                        todo={todo}
                                                        onToggle={toggleTodo}
                                                        onDelete={deleteTodo}
                                                        onUpdateDueDate={updateDueDate}
                                                    /> for todo in todos
                                                ]}
                                            </div>
```

`frontend.impl.jac`

```
@@ -9,15 +9,19 @@ impl app.fetchTodos -> None {

impl app.addTodo -> None {
    if not newTodoText.trim() { return; }
    response = root spawn AddTodo(title=newTodoText);
    newTodo = response.reports[0];
    todos = todos.concat([{
        "id": newTodo.id,
        "title": newTodo.title,
        "completed": newTodo.completed,
        "category": newTodo.category
    }]);
    response = root spawn AddTodo(title=newTodoText, due_date=dueDate);
    if response.reports and response.reports.length > 0 {
        newTodo = response.reports[0];
        todos = todos.concat([{
            "id": newTodo.id,
            "title": newTodo.title,
            "completed": newTodo.completed,
            "category": newTodo.category,
            "due_date": newTodo.due_date
        }]);
    }
    newTodoText = "";
    dueDate = "";
}

impl app.toggleTodo(todoId: str) -> None {
@@ -27,7 +31,7 @@ impl app.toggleTodo(todoId: str) -> None {
            if t.id == todoId {
                return {
                    "id": t.id, "title": t.title,
                    "completed": not t.completed, "category": t.category
                    "completed": not t.completed, "category": t.category, "due_date": t.due_date
                };
            }
            return t;
@@ -132,4 +136,23 @@ impl app.getIngredientsTotal -> float {
        total = total + ing.cost;
    }
    return total;
}

impl app.updateDueDate(todoId: str, date: str) -> None {
    root spawn UpdateDueDate(todo_id=todoId, due_date=date);

    todos = todos.map(
        lambda t: any -> any {
            if t.id == todoId {
                return {
                    "id": t.id,
                    "title": t.title,
                    "completed": t.completed,
                    "category": t.category,
                    "due_date": date
                };
            }
            return t;
        }
    );
}
```

`main.jac`

```
‎main.jac‎
+28
-4
Lines changed: 28 additions & 4 deletions
Original file line number	Diff line number	Diff line change
@@ -22,28 +22,29 @@

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
        category: str = "other",
        due_date: str = "";
}

node MealIngredient {
@@ -58,19 +59,22 @@

walker:priv AddTodo {
    has title: str;
    has due_date: str = "";

    can create with Root entry {
        category = str(categorize(self.title)).split(".")[-1].lower();
        new_todo = here ++> Todo(
            id=str(uuid4()),
            title=self.title,
            category=category
            category=category,
            due_date=self.due_date
        );
        report {
            "id": new_todo[0].id,
            "title": new_todo[0].title,
            "completed": new_todo[0].completed,
            "category": new_todo[0].category
            "category": new_todo[0].category,
            "due_date": new_todo[0].due_date
        };
    }
}
@@ -87,7 +91,8 @@
            "id": here.id,
            "title": here.title,
            "completed": here.completed,
            "category": here.category
            "category": here.category,
            "due_date": here.due_date
        });
    }

@@ -129,6 +134,25 @@
    }
}

walker:priv UpdateDueDate {
    has todo_id: str;
    has due_date: str;
    can search with Root entry {
        visit[-->];
    }
    can update with Todo entry {
        if here.id == self.todo_id {
            here.due_date = self.due_date;
            report {
                "id": here.id,
                "due_date": here.due_date
            };
        }
    }
}
# --- Meal Planner Walkers ---

walker:priv GenerateShoppingList {
```
