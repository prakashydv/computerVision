# -*- coding: utf-8 -*-
#
# Copyright (C) 2013 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Command-line skeleton application for Google Maps Coordinate API.
Usage:
  $ python sample.py

You can also get help on all the command-line flags the program understands
by running:

  $ python sample.py --help

"""

import argparse
import httplib2

import os
import sys
import Image,ImageDraw
import urllib, cStringIO
import math
import serial,time
import Tkinter
import ImageTk

from apiclient import discovery
from oauth2client import file
from oauth2client import client
from oauth2client import tools

# Parser for command-line arguments.
parser = argparse.ArgumentParser(
    description=__doc__,
    formatter_class=argparse.RawDescriptionHelpFormatter,
    parents=[tools.argparser])


# CLIENT_SECRETS is name of a file containing the OAuth 2.0 information for this
# application, including client_id and client_secret. You can see the Client ID
# and Client secret on the APIs page in the Cloud Console:
# <https://cloud.google.com/console#/project/1013420906965/apiui>
CLIENT_SECRETS = os.path.join(os.path.dirname(__file__), 'client_secrets.json')

# Set up a Flow object to be used for authentication.
# Add one or more of the following scopes. PLEASE ONLY ADD THE SCOPES YOU
# NEED. For more information on using scopes please see
# <https://developers.google.com/+/best-practices>.
FLOW = client.flow_from_clientsecrets(CLIENT_SECRETS,
  scope=[
      'https://www.googleapis.com/auth/coordinate',
      'https://www.googleapis.com/auth/coordinate.readonly',
    ],
    message=tools.message_if_missing(CLIENT_SECRETS))
def button_click_exit_mainloop (event):
  event.widget.quit() # this will cause mainloop to unblock.
def showmap(src_lat,src_lon,dest_lat,dest_lon,zoom,height,width):
  #src_lat*,src_lon*,dest_lat*,dest_lon*=math.PI/180,math.PI/180,math.PI/180,math.PI/180
  source=str(src_lat)+","+str(src_lon)
  destination=str(dest_lat)+","+str(dest_lon)
  center=str((src_lat+dest_lat)/2)+","+str((src_lon+dest_lon)/2)
  marker1="color:blue%7Clabel:1%7C"+source
  marker2="color:red%7Clabel:2%7C"+destination
  drawpath="color:0xff0000|weight:4|"+source+"|"+destination
  mapsize=str(height)+"x"+str(width)
  url="http://maps.googleapis.com/maps/api/staticmap?center="+center+"&zoom="+str(zoom)+"&size="+mapsize+"&maptype=hybrid&markers="+marker1+"&markers="+marker2+"&sensor=false&path="+drawpath
  #print url
  imgfile = cStringIO.StringIO(urllib.urlopen(url).read())
  img=Image.open(imgfile)
  #img.show()
  return img

def showtarget(rLat1,rLon1,distance,bearing,zoom,height,width):
  
  PI = 3.14159
  rLat1*=PI/180
  rLon1*=PI/180
  bearing*=PI/180
  R = 6371000.0
  rLat2 = math.asin( math.sin(rLat1)*math.cos(distance/R) + math.cos(rLat1)*math.sin(distance/R)*math.cos(bearing) )
  rLon2 = rLon1 + math.atan2(math.sin(bearing)*math.sin(distance/R)*math.cos(rLat1),(math.cos(distance/R)-math.sin(rLat1)*math.sin(rLat2)))
  return showmap(rLat1*180/PI,rLon1*180/PI,rLat2*180/PI,rLon2*180/PI,zoom,height,width)

def ahrs_getValue(port):
  time.sleep(0.2)
  reply=port.read(port.inWaiting())
  number =[]
  ln=len(reply)
  i=0
  while(i<ln):
    if(reply[i]=='='):
      i+=2
      while(i<ln and (reply[i] in ['.','e','+','-'] or (reply[i]>='0' and reply[i]<='9'))):
        number.append(reply[i])
        i+=1
      n=''.join(number)
      return float(n)
    i+=1
  return 0.0
def drawscope(im):
  draw = ImageDraw.Draw(im)
  draw.line((0, im.size[1]/2,im.size[0],im.size[1]/2), fill=255,width=2)
  draw.line((im.size[0]/2, 0,im.size[0]/2,im.size[1]), fill=255,width=2)
  draw.line((0,0,im.size[0],im.size[1]), fill=255)
  draw.line((0,im.size[1],im.size[0],0), fill=255,)
  
  del draw 
  return im
def getzoom(distance):
  if(distance < 50):
    m_zoom = 20
  if(distance < 100):
    m_zoom = 19
  elif( distance < 250):
    m_zoom = 18
  elif( distance < 500):
    m_zoom = 17
  elif( distance < 800):
    m_zoom = 16
  elif( distance >= 800):
    m_zoom = 15
  else:
    m_zoom = 18
  return m_zoom
  #return 20
   

def main(argv):
  # Parse the command-line flags.
  flags = parser.parse_args(argv[1:])

  # If the credentials don't exist or are invalid run through the native client
  # flow. The Storage object will ensure that if successful the good
  # credentials will get written back to the file.
  storage = file.Storage('sample.dat')
  credentials = storage.get()
  if credentials is None or credentials.invalid:
    credentials = tools.run_flow(FLOW, storage, flags)

  # Create an httplib2.Http object to handle our HTTP requests and authorize it
  # with our good Credentials.
  http = httplib2.Http()
  http = credentials.authorize(http)

  # Construct the service object for the interacting with the Google Maps Coordinate API.
  service = discovery.build('coordinate', 'v1', http=http)

  try:
    port = serial.Serial(port='COM3', baudrate=19200, timeout=5)
    #showmap(12.93539,77.62057,12.93689,77.62138,18,600,600)
    bearing_degrees=0
    Iter=10
    root = Tkinter.Tk()
    root.bind("<Button>",button_click_exit_mainloop)
    root.geometry('+%d+%d' % (100,100))
    old_label_image = None
    distance=200.0
    Bearing_ERR=0
    zoom=getzoom(distance)
    while Iter>0 :
      Iter-=1
      port.write("yawt di.\r")
      time.sleep(1)
      bearing_degrees=ahrs_getValue(port)
      bearing_degrees=(bearing_degrees+Bearing_ERR)%360


      image1 = showtarget(12.93539,77.62057,distance,bearing_degrees,zoom,600,600)
      image1=drawscope(image1)
      root.geometry('%dx%d' % (image1.size[0],image1.size[1]))
      tkpi = ImageTk.PhotoImage(image1)
      label_image = Tkinter.Label(root, image=tkpi)
      label_image.place(x=0,y=0,width=image1.size[0],height=image1.size[1])
      root.title("AHRS")
      print bearing_degrees
      try:
        root.mainloop()
      except:
        print "AUSGANG !!!"
        break

      #time.sleep(2)

    port.close()

  except client.AccessTokenRefreshError:
    print ("The credentials have been revoked or expired, please re-run"
      "the application to re-authorize")


# For more information on the Google Maps Coordinate API you can visit:
#
#   https://developers.google.com/coordinate/
#
# For more information on the Google Maps Coordinate API Python library surface you
# can visit:
#
#   https://developers.google.com/resources/api-libraries/documentation/coordinate/v1/python/latest/
#
# For information on the Python Client Library visit:
#
#   https://developers.google.com/api-client-library/python/start/get_started
if __name__ == '__main__':
  main(sys.argv)
