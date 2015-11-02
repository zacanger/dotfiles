import sys
from PyQt4 import QtCore

"""A very basic and limited plugin Interface,
but this is the one I understand.

The work is based upon an article I read here :
http://lucumr.pocoo.org/blogarchive/python-plugin-system

Thanks comes to Armin Ronacher for this article, but also
for all the other great articles and his projects :
Pocoo, Pygments, etc.
"""

# Maybe this ?
# class IPlugin(object,QtCore.QObject):
# def __init__(self,parent):
#        QtCore.QObject.__init__(self,parent)

class Singleton(object):
    _ref = None
    def __new__(cls, *args, **kargs):
        if cls._ref is None:
            cls._ref = object.__new__(cls, *args, **kargs)
        return cls._ref


class IPlugin(object):
    """Each plugin will inherit from this base class interface.

    activate and deactivate are the methods each plugin
    should implements to stick this interface.
    """
    infos = {}

    def __init__(self,parent):
        self.parent = parent

    ## Plugins activation/desactivation

    def activate(self):
        raise NotImplementedError

    def deactivate(self):
        raise NotImplementedError

class pluginManager(object):
    """The pluginManager is responsible of :

    - finding plugins in a given directory;
    - load them;
    - instanciate each class found inside the given directory;

    """
    def __init__(self, parent, config_dict):
        # generally the widget on witch the plugin acts
        self.parent = parent
        # a dictionnary containing theconfiguration
        self.config_dict = config_dict
        # plugins instances running
        self._instances = {}
        # plugins found
        self._plugins = []

    def activateAllPlugins(self):
        """Activate all the plugins found
        in plugins directory that implements
        the IPlugin interface.(subclasses of)
        """
        for plugin in self.find_plugins():
            name = plugin.infos['name']
            self._instances[name] = plugin(self.parent)
            self._instances[name].activate()

    def activate(self,plugin_name):
        """Given a plugin name (the one found
        inside the plugin's infos dictionnary),
        add an instance to self._instances.
        """
        for plugin in self.find_plugins():
            name = plugin.infos['name']
            if name == plugin_name :
                self._instances[name] = plugin(self.parent)
                self._instances[name].activate()
        print "%s has been activated successfully"%(plugin_name)

    def deactivate(self,plugin):
        """Given a plugin name (the one found
        inside the plugin's infos dictionnary),
        delete the instance from self._instances.
        """
        print "deactivate called, instances=\n", self._instances,'\n'
        print "%s has been deleted"%(str(plugin))
        del self._instances[plugin]


    def get_plugin_infos(self):
        plug_infos = []
        for plugin in self._instances:
            plug_infos.append(self._instances[plugin].infos)
            #return self._instances[plugin].infos
        return plug_infos

    def load_plugins(self,plugins):
        """Import all plugin modules found in 'plugins' variable.
        Add them to self._plugins.
        """
        for plugin in plugins:
            __import__(plugin, None, None, [''])
        self._plugins.append(self.find_plugins())

    def init_plugin_system(self):
        """Add the plugins path to environment
        the call the load plugins method
        """
        if not self.config_dict['plugin_path'] in sys.path:
            sys.path.insert(0, self.config_dict['plugin_path'])
        self.load_plugins(self.config_dict['plugins'])

    def find_plugins(self):
        """Return all subclasses of IPlugin
        """
        return IPlugin.__subclasses__()
