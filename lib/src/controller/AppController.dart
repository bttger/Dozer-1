part of dozergame;

class AppController {

  LevelController _levelController;

  /** The target framerate in hz */
  static const int framerate = 35;

  int _highscore = 0;
  Storage _reachedLevelStorage = window.localStorage;
  int _reachedLevel = 1;
  int _nrAvailableLevels;
  bool _gyroAvailable = true;

  void startup() {

    if(this._reachedLevelStorage.containsKey('reachedLevel')) {
      this._reachedLevel = int.parse(this._reachedLevelStorage['reachedLevel']);
    }
    // TODO dynamic level
    // Load level 1
    this.showLeveLOverview();

    // TODO load levels
    this._nrAvailableLevels = 10; //provisional

    // Check Gyrosensor Support
    window.onDeviceOrientation.first.then((e) {
      this._gyroAvailable = e.gamma != null ? true : false;
      if(!this._gyroAvailable) {
        this.showMessageNoSupportForGyro();
      } else {
        this.showWelcomeScreenOnMobileDevices();
      }
    });
  }

  void startNextLevel() {
    LevelController.loadAndStart(this, this._reachedLevel);
  }

  void startLevel(int level) {
    LevelController.loadAndStart(this, level);
  }

  void listenGoToMenuButton() {
    querySelector("#button_to_menu").onClick.listen((MouseEvent e) {
      this.showLeveLOverview();
    });
  }

  void listenGoToMenuButtonAndRequestFullscreen() {
    querySelector("#button_to_menu").onClick.listen((MouseEvent e) {
      this.showLeveLOverview();
      document.body.requestFullscreen();
      window.screen.orientation.lock("portrait-primary");
    });
  }

  void listenStartLevelButton() {
    querySelector("#button_start_level").onClick.listen((MouseEvent e) {
      this.startNextLevel();
    });
  }

  void listenNextLevelButton() {
    querySelector("#button_next_level").onClick.listen((MouseEvent e) {
      this._reachedLevel++;
      this._reachedLevelStorage["reachedLevel"] = this._reachedLevel.toString();
      if (this._reachedLevel > this._nrAvailableLevels) {
        this.showNoSuchLevel(this._reachedLevel);
      } else {
        this.showLeveLOverview();
      }
    });
  }

  void listenPreviousLevelButton() {
    querySelector("#button_pevious_level").onClick.listen((MouseEvent e) {
      this._reachedLevel--;
      this._reachedLevelStorage["reachedLevel"] = this._reachedLevel.toString();
      this.showLeveLOverview();
    });
  }

  void listenChooseLevelButton() {
    querySelector("#button_choose_levels").onClick.listen((MouseEvent e) {
      this.showMessageChooseLevels(this._nrAvailableLevels, this._reachedLevel);
    });
  }

  void listenAllLevelButtons(int reachedLevel) {
    for(int i = 1; i <= this._reachedLevel; i++) {
      querySelector("#button_level_$i").onClick.listen((MouseEvent e) {
        this.startLevel(i);
      });
    }
  }

  void listenCreditsButton() {
    querySelector("#button_credits").onClick.listen((MouseEvent e) {
      this.showMessageCredits();
    });
  }

  void showLeveLOverview() {
    MenuView.show().levelOverview(this._reachedLevel, "Catch The Dots To Grow The Dozer").render(); // this._levelController.level.instructions TODO waiting for dependency
    this.listenStartLevelButton();
    this.listenChooseLevelButton();
    this.listenCreditsButton();
  }

  void showMessageWin(int score, bool newHighscore) {
    MenuView.show().messageWin(score, newHighscore).render();
    this.listenNextLevelButton();
  }

  void showMessageLoose(bool timeout) {
    MenuView.show().messageLose(timeout).render();
    this.listenGoToMenuButton();
  }

  void showMessageNoSupportForGyro() {
    MenuView.show().messageNoSupportForGyro().render();
    this.listenGoToMenuButton();
  }

  void showWelcomeScreenOnMobileDevices() {
    MenuView.show().messageWelcomeScreenOnMobile().render(); // TODO replace with welcomeScreen
    this.listenGoToMenuButtonAndRequestFullscreen();
  }

  void showMessageChooseLevels(int nrAvailableLevels, int reachedLevel) {
    MenuView.messageChooseLevels(nrAvailableLevels, reachedLevel);
    this.listenGoToMenuButton();
    this.listenAllLevelButtons(reachedLevel);
  }

  void showMessageCredits() {
    MenuView.show().messageCredits().render();
    this.listenGoToMenuButton();
  }

  void showNoSuchLevel(int level) {
    MenuView.show().messageNoSuchLevel(level).render();
    this.listenPreviousLevelButton();
  }
}