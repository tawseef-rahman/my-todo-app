"""Todo item component."""

def:pub TodoItem(todo: dict, onToggle: any, onDelete: any) -> any {
    return
        <div className="todo-item">
            <input
                type="checkbox"
                checked={todo.completed}
                onChange={lambda -> None { onToggle(todo.id); }}
                className="todo-checkbox"
            />
            <span className={("todo-title-completed" if todo.completed else "todo-title")}>
                {todo.title}
            </span>
            {(
                <span className="category-badge">{todo.category}</span>
            ) if todo.category and todo.category != "other" else None}
            <button
                onClick={lambda -> None { onDelete(todo.id); }}
                className="todo-delete-btn"
            >
                ×
            </button>
        </div>;
}