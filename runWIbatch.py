import os
import sys, getopt
import re
from subprocess import call
import glob
from shutil import copyfile

#print 'Number of arguments:', len(sys.argv), 'arguments.'
#print 'Argument List:', str(sys.argv)

def main(argv):
   configFile = ''
   try:
      opts, args = getopt.getopt(argv,"hc:",["-configfile "])
   except getopt.GetoptError:
      print (argv[0],'runBatch.py -c <configfile>')
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print ('runBatch.py -configfile <configfile>')
         sys.exit()
      elif opt in ("-c", "-configfile"):
         configFile = arg
   print ('Config file is "', configFile)
   return configFile
   #...

def runGPU(xmlFile):
    print ('XML file is', xmlFile)
    #Run command
    #runcmd = 'wibatch -f '+ xmlFile + ' -out .\WI_out_test';
    runcmd = 'wibatch -f '+ xmlFile + ' -out ./x3d';
    print ('Running:' , runcmd) 
    #call(runcmd)
    os.system(runcmd)
    #...
    

if __name__ == "__main__":
  #Current directory
  scriptdir=os.getcwd()

  #Open the config file
  #fconfig=open(configFile,'r')

  #Get the simulation direcotry from the path of the config file
  simudir=os.getcwd()

  #Change the directory
  os.chdir(simudir)
  #print 'Current directory is', os.getcwd()

  for sim_idx in range(1, 1001):
    #Check if the line is a comment otherwise simulate it
    #if not re.search('^--.*',line):
    os.chdir(simudir)
    curdir='../tmp/sim_'+str(sim_idx)
    os.chdir(curdir)
    # copyfile('try.txt', '../../../../WIseed/try.txt')
    # copyfile('sd_2car.txrx', '../../../../WIseed/sd_2car.txrx')
    # copyfile('sd_2car.txrx', '../../../../sd_2car.txrx')
    print ('Running simulation for : ', os.getcwd())
      
    #Get the xml file name
    xmlFile=glob.glob("*.xml")
    # print((xmlFile[0]))
      
    #Run the command
    runGPU(xmlFile[0])
    os.chdir(simudir)
      

  #Close the config file
  # fconfig.close

  #Change the directory back to the directory of the script
  os.chdir(scriptdir)
