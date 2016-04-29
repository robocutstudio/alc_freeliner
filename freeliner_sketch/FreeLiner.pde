/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2014-12-01
 */

/**
 * Main class for alc_freeliner
 * Perhaps subclass features such as OSC, dedicated mouse device, slave mode...
 */
class FreeLiner implements FreelinerConfig{
  // model
  GroupManager groupManager;
  TemplateManager templateManager;
  // view
  TemplateRenderer templateRenderer;
  CanvasManager canvasManager; // new!
  Gui gui;
  // control
  Mouse mouse;
  Keyboard keyboard;
  Keymap keyMap;

  // new parts
  CommandProcessor commandProcessor;
  FreelinerCommunicator oscComs;
  WebSocketCommunicator webComs;

  // misc
  boolean windowFocus;
  PApplet applet;

  public FreeLiner(PApplet _pa) {
    applet = _pa;
    // instantiate
    // model
    groupManager = new GroupManager();
    templateManager =  new TemplateManager();
    // view
    templateRenderer = new TemplateRenderer();
    gui = new Gui();
    // pick a rendering system
    if(RENDERING_PIPELINE == 0) canvasManager = new ClassicCanvasManager();
    else if(RENDERING_PIPELINE == 1) canvasManager = new LayeredCanvasManager();
    // control
    mouse = new Mouse();
    keyboard = new Keyboard();
    commandProcessor = new CommandProcessor();

    // osc + webSocket
    oscComs = new OSCCommunicator(applet, commandProcessor);
    webComs = new WebSocketCommunicator(applet, commandProcessor);

    keyMap = new Keymap();

    // inject dependence
    mouse.inject(groupManager, keyboard);
    keyboard.inject(this);
    gui.inject(groupManager, mouse);
    templateManager.inject(groupManager);
    groupManager.inject(templateManager);
    commandProcessor.inject(this);
    canvasManager.inject(templateRenderer);
    windowFocus = true;
  }

  // sync message to other software
  void oscTick(){
    oscComs.send("freeliner tick");
  }

  void oscInfoLine(){
    oscComs.send("info "+gui.getInfo());
  }

  void webInfoLine(){
    webComs.send("info "+gui.getInfo());
  }

  void webseq(){
    String _stps = templateManager.getSequencer().getStatusString();
    webComs.send("webseq "+_stps);
  }

  /**
   * It all starts here...
   */
  public void update() {
    //autoSave();

    // windowFocus
    if(windowFocus != focused){
      keyboard.forceRelease();
      windowFocus = focused;
    }

    commandProcessor.processQueue();

    // update template models
    templateManager.update();
    templateManager.launchLoops();//groupManager.getGroups());

    // get templates to render
    ArrayList<RenderableTemplate> _toRender = new ArrayList(templateManager.getLoops());
    _toRender.addAll(templateManager.getEvents());

    canvasManager.render(_toRender);
  // image(canvasManager.getCanvas(),0,0);
  //  if(canvasManager instanceof EffectsCanvasManager) image((EffectsCanvasManager)canvasManager.getTopCanvas());

    gui.update();
    if(gui.doDraw()){
      // resetShader();
      image(gui.getCanvas(), 0, 0);
    }

  }

  // its a dummy for FreelinerLED
  public void reParse(){ }
  // its a dummy for others
  public void toggleExtraGraphics(){}

  // need to make this better.
  private void autoSave(){
    if(frameCount % 1000 == 1){
      // commandProcessor.processCMD("geom"+" "+"save"+" "+"userdata/autoSaveGeometry.xml");
      // commandProcessor.processCMD("tp"+" "+"save"+" "+"userdata/autoSaveTemplates.xml");
      // println("Autot saved");
    }
  }

  public void processCMD(String _cmd){
    commandProcessor.processCMD(_cmd);
  }

  public void queueCMD(String _cmd){
    commandProcessor.queueCMD(_cmd);
  }

  public void tracker(String _tag){
    TweakableTemplate _tp = templateManager.getTemplate(_tag.charAt(0));
    if(_tp == null) return;
    PVector _pos = _tp.getLastPosition();
    oscComs.send("freeliner tracker "+_tag.charAt(0)+" "+_pos.x/width+" "+_pos.y/height);
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    OSC feedback
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  // sync message to other software
  // void oscTick(){
  //   oscP5.send(tickmsg, toPDpatch);
  // }
  //
  // void oscInfoLine(){
  //   oscP5.send(new OscMessage("/freeliner/infoline").add(gui.getInfo()), toPDpatch);
  // }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Accessors
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  public Mouse getMouse(){
    return mouse;
  }

  public Keyboard getKeyboard(){
    return keyboard;
  }

  public Gui getGui(){
    return gui;
  }

  public GroupManager getGroupManager(){
    return groupManager;
  }

  public TemplateManager getTemplateManager(){
    return templateManager;
  }

  public TemplateRenderer getTemplateRenderer(){
    return templateRenderer;
  }

  public CommandProcessor getCommandProcessor(){
    return commandProcessor;
  }

  public CanvasManager getCanvasManager(){
    return canvasManager;
  }

  public PGraphics getCanvas(){
    return canvasManager.getCanvas();
  }

  ////////////////////////////////////////////////////////////////////////////////////
  ///////
  ///////    Debug
  ///////
  ////////////////////////////////////////////////////////////////////////////////////

  private void printStatus() {
    //merp
  }
}