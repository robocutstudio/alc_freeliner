/**
 * ##copyright##
 * See LICENSE.md
 *
 * @author    Maxime Damecour (http://nnvtn.ca)
 * @version   0.4
 * @since     2016-04-01
 */

// for detecting fields
import java.lang.reflect.Field;

/**
 * The FreelinerCommunicator handles communication with other programs over various protocols.
 */
class Documenter implements FreelinerConfig{
  ArrayList<ArrayList<Mode>> docBuffer;
  ArrayList<String> sections;
  PrintWriter markDown;
  PrintWriter javaScript;
  XML freelinerModes;
  IntDict modeLimits;


  /**
   * Constructor
   */
  public Documenter(){
    docBuffer = new ArrayList();
    sections = new ArrayList();
    // sections.add("First");

    markDown = createWriter("../doc/autodoc.md");
    markDown.println("// auto generated by freeliner");

    javaScript = createWriter("../webgui/freelinerConfig.js");
    javaScript.println("// auto generated by freeliner");

    freelinerModes = new XML("freelinerModes");
    modeLimits = new IntDict();
  }

  /**
   * Add a array of "modes", their associated key, and their section name.
   * @param Mode[] array of modes to be added to doc.
   * @param char key associated with mode slection (q for stroke color)
   * @param String section name (ColorModes)
   */
  void documentModes(Mode[] _modes, char _key, Mode _parent, String _section){

    if(!hasSection(_section)){
      sections.add(_section);
      addModesToMarkDown(_modes,_key,_parent);
      addModesToJS(_modes,_key,_parent);
      storeLimits(_key, _modes.length);

      // addDocToXML(_modes,_key,_section);
    }
  }
  void storeLimits(char _k, int _n){
    String _key = str(_k);
    if(modeLimits.hasKey(_key)){
      if(modeLimits.get(_key) < _n) modeLimits.set(_key, _n);
    }
    else modeLimits.add(_key, _n);
  }

  /**
   * As many things get instatiated we need to make sure we only add a section once
   * @param String sectionName
   */
  boolean hasSection(String _section){
    for(String _s : sections){
      if(_section.equals(_s)) return true;
    }
    return false;
  }

  public void doDocumentation(KeyMap _km){

    documentKeysMarkDown();
    markDown.flush();
    markDown.close();
    println(modeLimits);

    keyMapToJS(_km);
    updateJSVariables();
    javaScript.flush();
    javaScript.close();
    println("**** Documentation Updated ****");
  }

  public void keyMapToJS(KeyMap _km){
    javaScript.println("var keyMap = new Array(255);");
    for(ParameterKey _pk : _km.getKeyMap()){
      if(_pk != null){
        javaScript.print("keyMap["+int(_pk.getKey())+"] = {");
        javaScript.print("key:\""+_pk.getKey());
        javaScript.print("\", name:\""+_pk.getName());
        javaScript.print("\", cmd:\""+_pk.getCMD());
        javaScript.print("\", max:\""+_pk.getMax());
        javaScript.println("\", desc:\""+_pk.getDescription()+"\"};");
        // javaScript.println("var "+_pk.getKey()+"_CMD = '"+_pk.getCMD()+"';");
      }
    }
  }


  // public void keyMapToJS(KeyMap _km){
  //   for(ParameterKey _pk : _km.getKeyMap()){
  //     if(_pk != null){
  //       if(_pk.getKey()>)
  //       javaScript.println("var "+_pk.getKey()+"_CMD = '"+_pk.getCMD()+"';");
  //     }
  //   }
  // }

  /**
   * Creates markdown for keyboard shortcuts!
   */
  void documentKeysMarkDown(){
    // print keyboard type, osx? azerty?
    // markDown.println("### keys ###");
    // markDown.println("| key | parameter |");
    // markDown.println("|:---:|---|");
    // for(String _s : KEY_MAP){
    //   String _ks = _s.replaceAll(" ", "");
    //   markDown.println("| `"+_ks.charAt(0)+"` | "+_ks.substring(1)+" |");
    // }
    // markDown.println(" ");
    // markDown.println("### ctrl keys ###");
    // markDown.println("| key | action |");
    // markDown.println("|:---:|---|");
    // for(String _s : CTRL_KEY_MAP){
    //   String _ks = _s.replaceAll(" ", "");
    //   markDown.println("| `ctrl+"+_ks.charAt(0)+"` | "+_ks.substring(1)+" |");
    // }
    // markDown.println(" ");
  }


  /**
   * Format mode arrays to nice markdown tables
   * @param String cmd
   */
  void addModesToMarkDown(Mode[] _modes, char _key, Mode _parent){
    markDown.println("| "+_key+" |  for : "+_parent.getName()+" | Description |");
    markDown.println("|:---:|---|---|");
    int _index = 0;
    for(Mode _m : _modes){
      markDown.println("| `"+_index+"` | "+_m.getName()+" | "+_m.getDescription()+" |");
      _index++;
    }
    markDown.println(" ");
  }


  /**
   * Parse the config file to copy variables to a javascript thingy
   */
  void updateJSVariables(){
    Dummy  _dum = new Dummy();
    Field[] fields = _dum.getClass().getFields();
    for(Field _f : fields) {
      try {
        if(_f.getType().equals(int.class)) javaScript.println("var "+_f.getName()+" = "+_f.get(_dum)+";");
        else if(_f.getType().equals(boolean.class)) javaScript.println("var "+_f.getName()+" = "+_f.get(_dum)+";");
        else if(_f.getType().equals(String.class)) javaScript.println("var "+_f.getName()+" = '"+_f.get(_dum)+"';");
      }
      catch (Exception _e){ println("hah");}
    }
  }

  void addModesToJS(Mode[] _modes, char _key, Mode _parent){
    // int _index = 0;
    for(Mode _m : _modes){
      String _index = _key+str(_m.getIndex());
      if(_key == 'a') _index += "_b"+str(_parent.getIndex());
      javaScript.println("var "+_index+"_NAME = '"+_m.getName()+"';");
      javaScript.println("var "+_index+"_DESCRIPTION_ = '"+_m.getDescription()+"';");
      // _index++;
    }

  }
}


class Dummy implements FreelinerConfig{
  public Dummy(){}
}



/**
 * Format mode arrays to nice markdown tables
 * @param String cmd
 */
 // void outputXML(){
 //   saveXML(freelinerModes, "../webgui/freelinerModes.xml");
 // }
// void addDocToXML(Mode[] _modes, char _key, String _parent){
//   XML _param = freelinerModes.addChild("parameter");
//   _param.setString("key", str(_key));
//   int _index = 0;
//   for(Mode _m : _modes){
//     XML _mode = _param.addChild("mode");
//     _mode.setInt("index", _index);
//     _mode.setString("name", _m.getName());
//     _mode.setString("description", _m.getDescription());
//     _index++;
//   }
// }
