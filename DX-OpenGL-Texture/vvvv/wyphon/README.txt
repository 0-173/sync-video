SR Interprocess Sender test 01.v4p
SR Interprocess Receiver test 01.v4p


This is an example of the S+R nodes that should work between different vvvv instances.

Of course you need to start Sender and Receiver with different vvvv instances by using "vvvv.exe /allowmultiple".



_root_wyphon test 01.v4p

* You should start vvvv 2 times with /allowmultiple /dx9ex

* Start it once in vvvv 1 and move the main window to the side
* Then start it again in vvvv 2.
  (You will see that the Wyphon node will output a different Partner Id in both instances)

* Then in vvvv 1 click on 'Add Sender' 
  (and check if the sender shows its own shared texture, 
   I don't know why that doesn't work many times over here and 
   after closing and reopening the subpatch it starts working).

* In vvvv 2 you can click on 'Add Receiver' 
  and that one should receive the shared texture data 
  (even if it doesn't show the texture, you should see that the correct info 
   like width, height, handle, ... about the texture has been received).
