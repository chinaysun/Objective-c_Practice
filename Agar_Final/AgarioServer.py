#!/usr/bin/python

from twisted.internet.protocol import Factory, Protocol
from twisted.internet import reactor
from struct import *
from twisted.internet.task import LoopingCall
from time import time

MESSAGE_PLAYER_INFO = 0
MESSAGE_EATEN_FOOD_POSITIONS = 1
MESSAGE_WAITING_FOR_ENEMY =7 
MESSAGE_GAME_BEGIN = 8
MESSAGE_SINGLE_GAME_GOAL = 9

goalsMessages4Leaderboard = []

waitingMessages4OnlineGame = []

class MessageReader:

    def __init__(self, data):
        self.data = data
        self.offset = 0
        
    def readByte(self):
        retval = unpack('!B', self.data[self.offset:self.offset+1])[0]
        self.offset = self.offset + 1
        return retval
        
    def readInt(self):
        retval = unpack('!I', self.data[self.offset:self.offset+4])[0]
        self.offset = self.offset + 4
        return retval
    
    def readString(self):
        strLength = self.readInt()
        unpackStr = '!%ds' % (strLength)
        retval = unpack(unpackStr, self.data[self.offset:self.offset+strLength])[0]
        self.offset = self.offset + strLength
        return retval            

class MessageWriter:

    def __init__(self):
        self.data = ""
                    
    def writeByte(self, value):        
        self.data = self.data + pack('!B', value)
        
    def writeInt(self, value):
        self.data = self.data + pack('!I', value)
        
    def writeString(self, value):
        self.writeInt(len(value))
        packStr = '!%ds' % (len(value))
        self.data = self.data + pack(packStr, value)




class AgarioGame(Protocol):
    def __init__(self):
        self.inBuffer = ""
        self.playerName = None

    def connectionMade(self):
        self.factory.clients.append(self)
        print "clients are", self.factory.clients

        # send the message for leaderboard display
        for c in self.factory.clients:
            for m in goalsMessages4Leaderboard[-5:]:
                c.message(m)

       # send the waiting enemy message
        if waitingMessages4OnlineGame != []:
            for c in self.factory.clients:
                c.sendGameBegin()
                for m in waitingMessages4OnlineGame:
                    c.message(m)


    def connectionLost(self, reason):
        self.factory.clients.remove(self)
        if self.factory.clients == []:
            waitingMessages4OnlineGame = []

    def sendMessage(self, message):
        msgLen = pack('!I', len(message.data))
        self.transport.write(msgLen)
        self.transport.write(message.data)

    def sendGameBegin(self):
        message = MessageWriter()
        message.writeByte(MESSAGE_GAME_BEGIN)
        print "Game Begin!"
        self.sendMessage(message)


    def addGoalMessagesToArray(self, data):
        goalsMessages4Leaderboard.append(data)
        print "Reveive and save the single game goal message"

    def addWaitingMessageToArray(self, data):
        waitingMessages4OnlineGame.append(data)
        print "Receive and save waiting message"

    def resendPlayerInfo(self, data):
        for c in self.factory.clients:
            c.message(data)
        print "Receive and resent the player information"

    def resendEatenFoodPositons(self, data):
        for c in self.factory.clients:
            c.message(data)
        print "Receive and resent the eaten food positions"

    def processMessage(self, message, data):
        messageId = message.readByte()        
        
        print "received message id is %d" % messageId

        if messageId == MESSAGE_SINGLE_GAME_GOAL:            
            return self.addGoalMessagesToArray(data)
        if messageId == MESSAGE_PLAYER_INFO:
            return self.resendPlayerInfo(data)
        if messageId == MESSAGE_EATEN_FOOD_POSITIONS:
            return self.resendEatenFoodPositons(data)
        if messageId == MESSAGE_WAITING_FOR_ENEMY:
            return self.addWaitingMessageToArray(data)
                                    
        self.log("Unexpected message: %d" % (messageId))


    def dataReceived(self, data):
        print data

        self.inBuffer = self.inBuffer + data

        while(True):
            if (len(self.inBuffer) < 4):
                return;
            
            msgLen = unpack('!I', self.inBuffer[:4])[0]
            if (len(self.inBuffer) < msgLen):
                return;
            
            messageString = self.inBuffer[4:msgLen+4]
            self.inBuffer = self.inBuffer[msgLen+4:]
            
            message = MessageReader(messageString)
            self.processMessage(message, data)         


    def message(self, message):
        print "send %s" % message
        self.transport.write(message)

factory = Factory()
factory.protocol = AgarioGame
factory.clients = []
reactor.listenTCP(910, factory)
print "Agario server started"
reactor.run()


