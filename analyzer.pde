import ddf.minim.analysis.*;
import ddf.minim.*;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;

Minim minim;  
AudioPlayer player;
FFT fft_r;
FFT fft_l;

// Change these according to song you're painting
// Will be used to calculate rotation speed
int song_minutes = 3;
int song_seconds = 23;

// Number of frames needed for a full rotation
int total_frames = (30 * (song_minutes * 60 + song_seconds));

int count = 0;
int datasize = total_frames * 4098;
float data[] = new float[datasize];

void setup()
{
  size(30,30);
  frameRate(30);
  
  System.out.println("Working Directory = " +
              System.getProperty("user.dir"));
  
  // Change audio file here
  minim = new Minim(this);
  //player = minim.loadFile("/Users/oday/code/git/processing-toys/mp3/prologue.mp3", 4096);
  player = minim.loadFile("C:/cygwin64/home/Oday/code/git/processing-toys/mp3/si.mp3", 4096);
  
  player.play();

  fft_r = new FFT( player.bufferSize(), player.sampleRate() );
  fft_l = new FFT( player.bufferSize(), player.sampleRate() );
}

void draw()
{
  fft_r.forward( player.right );
  fft_l.forward( player.left );
  
  if (frameCount % 30 == 0) {
    println("on " + player.position()/1000 + "/" + total_frames/30 + "s at " + frameRate + " fps ");
  }

  // print(count + " ");
  for (int i=0; i<fft_r.specSize(); i++) {
    data[count*4098 + i + 2049] = fft_r.getBand(i);
    data[count*4098 + i       ] = fft_l.getBand(i);
  }
  count++;
  if ( count == total_frames ) {  
    //write_to_file("/Users/oday/code/git/processing-toys/mp3/prologue.dat", data, datasize);
    write_to_file("C:/cygwin64/home/Oday/code/git/processing-toys/mp3/si.dat", data, datasize);
    exit();
  }
}

void write_to_file(String filename, float[] data, int size) {
  
  println("Writing to file...");
  try {
  FileOutputStream fos = new FileOutputStream(filename);
  BufferedOutputStream bos = new BufferedOutputStream(fos);
  
  int intBits;
  
  for (int i=0; i < size; i++) {
    intBits = Float.floatToIntBits(data[i]);
    bos.write( 
      (new byte[] {(byte) (intBits >> 24), (byte) (intBits >> 16), (byte) (intBits >> 8), (byte) (intBits)}), 0, 4
    );
  }
    bos.flush();
    fos.flush();
    bos.close();
    println("Wrote " + size + " floats to file.");
  
  } catch (Exception e) {
    println("Could not write to file");
    println(e.getMessage());
    exit();
  }
  
}
