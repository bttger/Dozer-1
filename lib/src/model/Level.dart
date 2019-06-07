part of dozergame;

class Level {

  Dozer _dozer;

  /** Time limit in ms */
  double timeLimit;
  int initialScore;
  int targetScore;
  int tries;

  /** Equals the percentage which certain entities (such as Brick, Dot) move per second */
  double laneSpeed;
  int _level;

  Map<int, Entity> visibleEntities = new Map<int, Entity>();
  List<Entity> remainingEntities;

  int initialTime;

  // TODO probably provisional
  int viewWidth;
  int viewHeight;

  /// Fields to keep track of power up´s
  List<Future> slowDownFutures = List();
  bool slowDownActive = false;

  /**
   * Creates a new level
   */
  Level(int timeLimit, int initialScore, int targetScore, double laneSpeed, int level, int height, int width) {
    this._level = level;
    this.timeLimit = timeLimit.toDouble();
    this.initialTime = timeLimit;
    this.initialScore = initialScore;
    this.targetScore = targetScore;
    this.laneSpeed = laneSpeed;
    this.viewHeight = height;
    this.viewWidth = width;

    this._dozer = new Dozer(this);
    this.visibleEntities.putIfAbsent(this._dozer.id, () => this._dozer);
  }

  /**
   * Changes the time limit of the level.
   * The provided change is in seconds.
   * Provide a positive change to increase the time limit,
   * a negative change to decrease the time limit.
   */
  void changeTimeLimit(double change) {
    // If the game is slowed the time is also slowed
    if (this.slowDownActive) {
      change = change * SlowDown.POWER;
    }
    this.timeLimit += change;
  }

  /**
   * Changes the lane speed of the level.
   * Provide a positive change to increase the lane speed,
   * a negative change to decrease the lane speed.
   */
  void changeLaneSpeed(int change) {
    this.laneSpeed += change;
  }

  /**
   * Returns the current score
   */
  int getScore() {
    return (this.timeLimit * 1.357).floor() + this._dozer.score * 537;
  }

  /**
   * Return the current level
   */
  int getLevel() {
    return this._level;
  }

  /**
   * Returns the Dozer object
   */
  Dozer getDozer() {
    return this._dozer;
  }

  /**
   * Returns an immutable map of all currently visible entities
   * The key value pair of a map entry is:
   * <ID of entity | entity>
   */
  Map<int, Entity> getVisibleEntities() {
    return Map<int, Entity>.from(this.visibleEntities);
  }

  /**
   * Updates all necessary entities
   * This will probably be called every 50ms
   */
  void update() async {
    this.visibleEntities.forEach((id, e) => e.update());
    this.addNewlyVisibleEntities();
    this.removeInvisibleEntities();
    this.updateDozerTailInVisibleEntities();
    this.checkCollisions();
  }

  /**
   * Checks collision of all visible entities with the dozer
   * This will probably be called every 50ms
   */
  void checkCollisions() async {
    this.getVisibleEntities().forEach((id, e) {
      if (e is Brick || e is Barrier) {
        if(CollisionChecker.recCir(e, this._dozer)) {
          this._dozer.hitBy(e);
          e.hitBy(this._dozer);
          if (e is Brick) {
            visibleEntities.remove(id);
          }
        }
      } else if (e is Dot || e is PowerUp) {
        if(CollisionChecker.circles(e, this._dozer)) {
          this._dozer.hitBy(e);
          e.hitBy(this._dozer);
          visibleEntities.remove(id);
        }
      }
    });
  }

  /**
   * Adds all entities that became visible since the last update
   * This will probably be called every 50ms
   */
  void addNewlyVisibleEntities() async {
    Entity next;
    double scrolled = this.viewHeight * this.laneSpeed * (this.initialTime - this.timeLimit) / 1000;

    List<Entity> remEnt = List.from(remainingEntities);

    double lastY;
    int lastH;

    remEnt.forEach((e) {

      if (lastY != null && e.y < lastY && e.y + e.height < lastY + lastH) {
        return;
      }

      lastY = e.y;
      lastH = e.height;

      if (e.y + e.height + scrolled >= 0) {
        e.y = e.y + scrolled.floor();
        visibleEntities.putIfAbsent(e.id, () => e);
        remainingEntities.remove(e);
      }

    });
  }

  /**
   * Removes invisible entities mainly entities that scrolled past the viewport
   * from the visibileEntities Map
   */
  void removeInvisibleEntities() async {
    this.getVisibleEntities().forEach((id, e) {
      if (this.viewHeight < e.y) {
        this.visibleEntities.remove(id);
      }
    });
  }

  /// Gets the distance in pixel depending on duration and lanespeed
  double getRemainingYFromTime(int ms) {
    return this.viewHeight * laneSpeed * ms / -1000;
  }

  /// Gets the distance a scrolling entity (like a Brick or Dot) moves per frame
  double getVerticalMovementPerUpdate() {
    return this.viewHeight * this.laneSpeed / AppController.framerate;
  }

  /// Returns true if the game is won, false otherwise
  bool gameWon() {
    return this.getDozer().score >= this.targetScore;
  }

  /// Returns true if the game is lost, false otherwise
  bool gameLost() {
    return this.timeLimit <= 0 || this.getDozer().score <= 0;
  }

  /// Adds or removes dozer tail entities depending on the current score
  void updateDozerTailInVisibleEntities() async {
    // add tail entities to visible entities list
    this._dozer.tailEntities.forEach((e) {
      this.visibleEntities.putIfAbsent(e.id, () => e);
    });

    // remove
    for(int i = this._dozer.tailEntities.length + 1; this.visibleEntities.containsKey(-1 * i); i++){
      this.visibleEntities.remove(-1*i);
    }
  }
}