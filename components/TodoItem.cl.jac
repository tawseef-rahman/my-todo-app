"""Todo item component."""

def:pub TodoItem(todo: dict, onToggle: any, onDelete: any, onUpdateDueDate: any) -> any {
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
            <input
                type="date"
                value={todo.due_date}
                onChange={lambda e : any -> None { onUpdateDueDate(todo.id, e.target.value); }}
                className="todo-date"
            />
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