class Todo {
  final String title;
  final String description;


  Todo(this.title, this.description);
}
final todos = List<Todo>.generate(
  3,
      (i) => Todo(
    'Todo $i',
    'A description of what needs to be done for Todo $i',
  ),
);
