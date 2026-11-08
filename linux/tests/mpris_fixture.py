"""A real D-Bus/MPRIS player, independent of Spotify and network services."""
import dbus, dbus.service, dbus.mainloop.glib
from gi.repository import GLib
import time
ROOT='org.mpris.MediaPlayer2';PLAYER=ROOT+'.Player';PROPS='org.freedesktop.DBus.Properties'
dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
class Fixture(dbus.service.Object):
    def __init__(self,bus):
        self.name=dbus.service.BusName(ROOT+'.AfterglowFixture',bus=bus)
        super().__init__(bus,'/org/mpris/MediaPlayer2')
        self.status='Paused';self.position=1_000_000;self.title='Fixture Song';self.rate=1.0
    def values(self,interface):
        if interface==ROOT:return {'Identity':'Afterglow Fixture','CanQuit':False,'CanRaise':False,'HasTrackList':False,'SupportedUriSchemes':dbus.Array([],signature='s'),'SupportedMimeTypes':dbus.Array([],signature='s')}
        return {'PlaybackStatus':self.status,'LoopStatus':'None','Rate':self.rate,'Shuffle':False,'Metadata':dbus.Dictionary({'mpris:trackid':dbus.ObjectPath('/fixture/track'),'mpris:length':dbus.Int64(120_000_000),'xesam:title':self.title,'xesam:artist':dbus.Array(['Fixture Artist'],signature='s'),'xesam:album':'Fixture Album'},signature='sv'),'Volume':1.0,'Position':dbus.Int64(self.position),'MinimumRate':1.0,'MaximumRate':1.0,'CanGoNext':True,'CanGoPrevious':True,'CanPlay':True,'CanPause':True,'CanSeek':True,'CanControl':True}
    @dbus.service.method(PROPS,in_signature='ss',out_signature='v')
    def Get(self,interface,name):return self.values(interface)[name]
    @dbus.service.method(PROPS,in_signature='s',out_signature='a{sv}')
    def GetAll(self,interface):return self.values(interface)
    @dbus.service.method(PROPS,in_signature='ssv')
    def Set(self,interface,name,value):pass
    @dbus.service.signal(PROPS,signature='sa{sv}as')
    def PropertiesChanged(self,interface,changed,invalidated):pass
    @dbus.service.signal(PLAYER,signature='x')
    def Seeked(self,position):pass
    def update(self):self.PropertiesChanged(PLAYER,self.values(PLAYER),[])
    @dbus.service.method(PLAYER)
    def PlayPause(self):self.status='Paused' if self.status=='Playing' else 'Playing';self.update()
    @dbus.service.method(PLAYER)
    def Play(self):self.status='Playing';self.update()
    @dbus.service.method(PLAYER)
    def Pause(self):self.status='Paused';self.update()
    @dbus.service.method(PLAYER)
    def Stop(self):self.status='Stopped';self.position=0;self.update()
    @dbus.service.method(PLAYER)
    def Next(self):self.title='Next Fixture Song';self.position=0;self.update()
    @dbus.service.method(PLAYER)
    def Previous(self):self.title='Fixture Song';self.position=0;self.update()
    @dbus.service.method(PLAYER,in_signature='ox')
    def SetPosition(self,track,position):self.position=position;self.Seeked(position)
    @dbus.service.method(PLAYER,in_signature='x')
    def Seek(self,offset):self.position=max(0,self.position+offset);self.Seeked(self.position)
Fixture(dbus.SessionBus());print('MPRIS fixture ready',flush=True);GLib.MainLoop().run()
