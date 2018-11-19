# VIDEO_SEGMENTAION_AND_PLAY_HLS
instruction for segmenting and playing your own video


# STEPS
1. segment video

use file create-vod-hls.sh to segment test video
command: ./create-vod-hls.sh test.mp4

2. play video

STEP 1: download codes from hls.js gitHub. (https://github.com/video-dev/hls.js/)
command: git clone https://github.com/video-dev/hls.js.git

STEP 2: install dependencies

command: npm install hls.js

STEP 3: install

command:
cd hls.js
npm install

STEP 4: run server

command: npm run dev

3. check demo

browse http://localhost:8000/
click demo

4. use your own video

replace this line hls.loadSource('playlist.m3u8'); in file test.html.
playlist.m3u8 is the file you generated from 1

and click test.html


# COMMON QUESTIONS
1. How can I change the segmention duration?

change line segment_target_duration=0.5 #secs
and line key_frames_interval=12
(1 sec, the interval should be 24.)

2. Why my own video does not work?
step 1: check if your browser support hls.js by using interface Hls.isSupported(). 

        You can check it in the file test.html.

step 2: make sure your m3u8 file path is correct.

        for example, in my enviroment, I put all ts files in the same path, so in m3u8 file, just write the file name 720p.m3u8 in fule playlist.m3u8
        you can also check your path in the console through opening the inspect implement tool.
        if your path is wrong, console will report the errors.
        

