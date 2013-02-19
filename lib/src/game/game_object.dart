part of game;

abstract class GameObject {

  int _speed = 5;

  int _x = 0;
  int _y = 0;

  int _oldX = 0;
  int _oldY = 0;

  Direction _dir;

  Component _control;

  Level _level;
  bool _remove = false;

  DrawingComponent _drawer;

  int get tileWidth;
  int get tileHeight;
  DrawingComponent get drawer => this._drawer;

  Sprite getStaticSprite();
  Sprite getMoveSprite();

  int get x => this._x;
  int get y => this._y;
  int get oldX => this._oldX;
  int get oldY => this._oldY;
  Direction get dir => this._dir;
  int get numSteps => 9;
  Level get level => this._level;
  bool get isRemoved => this._remove;

  void remove() {
    window.console.log("removed");
    this._remove = true;
  }

  GameObject(this._dir, this._x, this._y);

  void setControlComponent(Component c) {
    this._control = c;
  }

  void setDrawingComponent(DrawingComponent d) {
    this._drawer = d;
  }

  void setLevel(Level l) {
    this._level = l;
  }

  void setSpeed(int s) {
    this._speed = s;
  }

  void setPos(int x, int y) {
    this._x = x;
    this._y = y;
  }

  /**
   * This object got hit by something.
   */
  void takeHit();

  void update() {

    this._oldX = this.x;
    this._oldY = this.y;
    this._control.update(this);
    if (this._drawer != null) {
      this._drawer.update(this);
    }
  }

  void moveUp() {
    this._dir = DIR_UP;
    this._y -= this._speed;
  }
  void moveDown() {
    this._dir = DIR_DOWN;
    this._y += this._speed;
  }
  void moveLeft() {
    this._dir = DIR_LEFT;
    this._x -= this._speed;
  }
  void moveRight() {
    this._dir = DIR_RIGHT;
    this._x += this._speed;
  }

  void faceUp() {
    this._dir = DIR_UP;
  }
  void faceDown() {
    this._dir = DIR_DOWN;
  }
  void faceLeft() {
    this._dir = DIR_LEFT;
  }
  void faceRight() {
    this._dir = DIR_RIGHT;
  }

  void broadcast(GameEvent e, Collection<ComponentListener> listeners) {
    for (ComponentListener l in listeners) {
      l.listen(e);
    }
  }
}

