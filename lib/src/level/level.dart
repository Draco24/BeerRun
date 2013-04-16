
part of level;

abstract class Level implements ComponentListener {

  // Level design parameters
  int _rows;
  int _cols;

  int _tileWidth;
  int _tileHeight;          //

  Duration _duration = null; // how long you have to beat this level

  List<bool> _blocked;      // blocked tiles
  List<Trigger> _triggers;  // triggered tiles

  TutorialManager _tutorial;

  // Level functionality members
  int _layer = -1;

  CanvasManager _manager;
  DrawingInterface _drawer;

  List<Animation> _animations;
  List<List<Sprite>> _sprites;
  List<GameObject> _objects;
  Player _player;

  bool _paused = false;

  Level(this._drawer, this._manager, this._duration,
      this._rows, this._cols, this._tileWidth, this._tileHeight)
  {
    this._sprites = new List<List<Sprite>>();
    this._objects = new List<GameObject>();
    this._animations = new List<Animation>();
    this._triggers = new List<Trigger>(); // TODO: someday optimize this to be more location aware
    this._blocked = new List<bool>
      .filled(this._rows * this._cols, false);
    this._tutorial = new TutorialManager();
  }

  // Abstract methods
  int get storeX;
  int get storeY;
  int get startX;
  int get startY;
  int get beersToWin;
  void setupTutorial(UI ui, Player p);

  int get tileWidth => this._tileWidth;
  int get tileHeight => this._tileHeight;
  int get rows => this._rows;
  int get cols => this._cols;
  CanvasManager get canvasManager => this._manager;
  CanvasDrawer get canvasDrawer => this._drawer;
  Duration get duration => this._duration;
  List<GameObject> get objects => this._objects;
  TutorialManager get tutorial => this._tutorial;

  int _posToIdx(int row, int col) {
    return this._cols * row + col;
  }

  void newLayer() {
    this._sprites.add(new List<Sprite>(this._rows * this._cols));
    this._layer++;
  }

  void pause() {
    this._paused = true;
  }
  void unPause() {
    this._paused = false;
  }
  bool isPaused() {
    return this._paused;
  }

  void setSpriteAt(Sprite s, int row, int col, [bool blocked]) {

    int pos = this._posToIdx(row, col);
    if (this._layer == -1 ||
        pos < 0 ||
        pos >= this._sprites[this._layer].length)
    {
      return;
    }

    if (?blocked) {
      this._blocked[pos] = blocked;
    }
    this._sprites[this._layer][pos] = s;
  }
  Sprite getSpriteAt(int row, int col) {

    int pos = this._posToIdx(row, col);
    if (this._layer == -1 ||
        pos < 0 ||
        pos >= this._sprites[this._layer].length)
    {
      return null;
    }

    return this._sprites[this._layer][pos];
  }

  void addPlayerObject(Player p) {
    this._player = p;
    this._player.setPos(this.startX, this.startY);
    this.addObject(p);
  }

  void addAnimation(Animation a) {
    this._animations.add(a);
  }

  void addTrigger(Trigger t) {
    this._triggers.add(t);
  }

  void addObject(GameObject obj) {
    this._objects.add(obj);
  }

  void removeObject(GameObject obj) {
    this._objects.remove(obj);
  }

  bool isOffscreen(GameObject obj) {
    return (obj.x < 0 || obj.x > this._cols * this._tileWidth ||
        obj.y < 0 || obj.y > this._rows * this._tileHeight);
  }

  void takeHit() {}

  bool isBlocking(int row, int col) {
    //return false;
    int pos = this._posToIdx(row, col);
    if (this._layer == -1 ||
        pos < 0 ||
        row >= this._rows ||
        col >= this._cols ||
        pos >= this._blocked.length)
    {
      // Keep us on the screen
      return true;
    }
    return this._blocked[pos];
  }

  List<GameObject> checkCollision(GameObject obj) {
    List<GameObject> targets = null;
    for (GameObject o in this._objects) {
      if (o != obj &&
          (
              (
                  o.x + o.tileWidth >= obj.x &&
                  o.x <= obj.x + obj.tileWidth
              )
              &&
              (
                  o.y + o.tileHeight >= obj.y &&
                  o.y <= obj.y + obj.tileHeight
              )
          )
      )
      {
        if (targets == null) {
          targets = new List<GameObject>();
        }
        targets.add(o);
      }
    }
    return targets;
  }

  GameObject collidesWithPlayer(GameObject obj) {

    GameObject o = this._player;
    if (o != obj &&
      (
          (
            o.x + o.collisionXOffset+ o.collisionWidth >= obj.x &&
            o.x + o.collisionXOffset <= obj.x + obj.tileWidth
          )
          &&
          (
            o.y + o.collisionYOffset + o.collisionHeight >= obj.y &&
            o.y + o.collisionYOffset <= obj.y + obj.tileHeight
          )
        )
      )
    {
      return o;
    } else {
      return null;
    }
  }

  void listen(GameEvent e) {
    if (e.type == GameEvent.CREATE_BULLET_EVENT) {
      Direction d = e.data["direction"];
      GameObject creator = e.creator;
      int x = e.data["x"];
      int y = e.data["y"];

      Bullet b = new Bullet(this, creator, d, x, y,
          new BulletInputComponent(),
          new DrawingComponent(this._manager, this._drawer, false));
      this.addObject(b);
    }
  }

  void update() {

    // Eventually, it would be cool if drawing could be moved out of the
    // main update loop.  How we do it, I'm not positive, but I'm thinking we
    // could just call window.requestDrawFrame or whatever and pass in the main
    // draw() function, and have update() called in an interval where we
    // regulate the speed with an updatesPerSecond counter.  This would allow
    // us to better control start/stops of the update loop too, and make it
    // easier to pass in different update() functions for different modes of
    // the game.
    // TODO: for now I'm just moving player.draw() out of here, and that'll
    //    have to be called explicitly from the game's loop.
    this.draw(this._drawer);


    if ( ! this._paused) {
      //this._player.update();
      // TODO: don't draw here!  Draw in game.update().
      //this._player.draw();

      // Check if the player is standing on a trigger
      for (Trigger t in this._triggers) {
        int x = t.col * this._tileWidth;
        int y = t.row * this._tileHeight;
        this._drawer.drawRect(x, y, this._tileWidth, this.tileHeight);
        GameObject o = this._player;
        if (
            (
                o.x + o.collisionXOffset + o.collisionWidth >= x &&
                o.x + o.collisionXOffset <= x + this.tileWidth
            )
            &&
            (
                o.y + o.collisionYOffset + o.collisionHeight >= y &&
                o.y + o.collisionYOffset <= y + this.tileHeight
            )
          ) {
            GameEvent e = t.event;
            Timer.run(() => o.listen(e));
        }
      }

      // Loop through the objects, calling update on each.  Remove them from the
      // list if they become removed from the level.
      this._objects = new List<GameObject>.from(this._objects.where((GameObject o)
      {
        if ( ! this._paused) {
          o.update();
        }

        // TODO: fuuuuuuuuuck this is so terrible
        if (o != this._player) {
          o.draw();
        }
        return ! o.isRemoved;
      }));

      if ( ! this._paused) {
        // Process any animations going on
        this._animations = new List<Animation>.from(
            this._animations.where((Animation a) {
              a.drawNext(this._drawer);
              return ! a.isDone;
            })
        );
      }
    }
  }

  // The main draw function.  Please see above for some rationale for moving
  // this out of the update() function.
  void draw(CanvasDrawer d) {

    for (List<Sprite> layer in this._sprites) {

      int row = 0;
      int col = 0;
      for (Sprite s in layer) {
        if (s != null) {
          d.drawSprite(s, col * this._tileWidth, row * this._tileHeight/*,
              this._tileWidth, this._tileHeight*/);
        }
        //if (this.isBlocking(row, col)) {
          //d.backgroundColor = "red";
          //d.drawRect(col * this._tileWidth, row * this._tileHeight,
          //    this._tileWidth, this._tileHeight, 0, 0, true);
        //}
        col++;
        if (col >= this._cols) {
          row++;
          col = 0;
        }
      }
    }
  }

  static Map<String, Sprite> parseSpriteSheet(
      SpriteSheet sheet, Map<String, List<int>> data)
  {

    Map<String, Sprite> sprites = new Map<String, Sprite>();

    for (String sName in data.keys) {
      int x = data[sName][0];
      int y = data[sName][1];
      sprites[sName] = sheet.spriteAt(x, y);
    }

    return sprites;
  }

  Sprite getStaticSprite() {}
  Sprite getMoveSprite() {}
}
