#!/usr/bin/env python 
"""
Validation between pynga and OpenSHA 
Both Distance calculation and 
Median & Standard deviation calculations
"""
import os, sys, glob 
import numpy as np 
import matplotlib.pyplot as plt 

from my_util.image import * 

from pynga import *
from pynga.utils import *

# keep in mind that you should consider BBP as the final application of pynga 
# ...
class NGAsValidation:
    """
    Validation of NGA models (median and sigmas)
    """
    def __init__(self, wrk, OFilePth, PFilePth, nga):
	
	self.wrk = wrk
	self.OFilePth = OFilePth
        
	self.nga = nga 
	self.NGAmodel = self.nga + '08'
	
	self.PFilePth = PFilePth
	if not os.path.exists( self.PFilePth ): 
	    os.mkdir( self.PFilePth ) 
	
	self.plotpth = wrk + '/plots'
	if not os.path.exists( self.plotpth ): 
	    os.mkdir( self.plotpth ) 
	pltpth0 = self.plotpth + '/' + self.NGAmodel 
	self.pltpth1 = pltpth0 + '/' + 'RMS'
	self.pltpth2 = pltpth0 + '/' + 'Scatter'
	for f in [pltpth0, self.pltpth1, self.pltpth2]:
	    if not os.path.exists( f ):
		os.mkdir( f )

	# Period List for NGA models
	TsDict = {
		'BA': [0.01, 0.02, 0.03, 0.05, 0.075, 0.10, 0.15, 0.20, 0.25,
		      0.30, 0.40, 0.50, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0,-1,-2],   # last two: PGA, PGV, 
		'CB': [0.01, 0.02, 0.03, 0.05, 0.075, 0.10, 0.15, 0.20, 0.25,
		      0.30, 0.40, 0.50, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0,-1,-2],    
		'CY': [0.01, 0.02, 0.03, 0.04, 0.05, 0.075, 0.10, 0.15, 0.20, 0.25,
		      0.30, 0.40, 0.50, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0,-1,-2],    
		'AS': [0.01, 0.02, 0.03, 0.04, 0.05, 0.075, 0.10, 0.15, 0.20, 0.25,
		      0.30, 0.40, 0.50, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.5, 10.0,-1,-2],    
		}

	self.periods = TsDict[nga] 
	self.NT = len(self.periods) 
        
	headers = 9*'%s   '%('Mw','Rrup','Rjb','Rx','Dip','W','Ztor','Vs30','Zsed')
	Str = ''; xlabs = []
	for ip in xrange( self.NT ):
	    Ti = self.periods[ip]
	    if Ti == -1: 
		Str += 'PGA    '
		xlabs.append( 'PGA' )
	    if Ti == -2:
		Str += 'PGV'  
		xlabs.append( 'PGV' )
	    if Ti not in [-1,-2]:
		Str += 'SA%.3f    '%Ti
		xlabs.append( '%s'%'%.3f'%Ti )

	self.FileHeaders = headers + Str
        self.xlabs = xlabs 

	self.pfmt = 'png' 
        

    def CalcNGA_Py(self):
	"""
	Compute NGA values using pynga 
	and save to files
	"""
	inpth = self.OFilePth + '/' + self.NGAmodel
	outpth = self.PFilePth + '/' + self.NGAmodel
	if not os.path.exists( outpth ): 
	    os.mkdir( outpth )
	
	# initial values for the keywords
	ArbCB = 0
	VsFlag = 0
	Fas = 0 
	Fhw = 0

	Files1 = glob.glob(inpth+'/*') 
	for file1 in Files1: 
	    spl = file1.strip().split('/')[-1]    # file name
	    spl0 = spl.strip().split('_')
	    if len(spl0)<=2:
		continue
            
	    elif len(spl0) == 3: 
		IMT = spl0[1]
		Ftype = spl0[-1].strip().split('.')[0] 

	    elif len(spl0) == 5: 
		IMT = spl0[1] 
		HWflag = spl0[3] 
		ASflag = spl0[2] 
		Ftype = spl0[-1].strip().split('.')[0]
            
		if ASflag == 'AS': 
		    Fas = 1
		else: 
		    Fas = 0
		if HWflag == 'HW':
		    Fhw = 1
		else: 
		    Fhw = 0
 
            # Cases for BA 
	    if IMT[3:] == 'TU': 
		Ftype = 'U'
            
	    # Cases for CB 
            if IMT[3:] == 'ARB':
		ArbCB = 1
	    if IMT[3:] == 'MEAN':
		ArbCB = 0
	
	    # Cases for AS and CY
	    if IMT[3:] in [ 'INFER', 'EST']: 
		VsFlag = 0 
	    if IMT[3:] == 'MEAS': 
		VsFlag = 1

	    tmp = np.loadtxt( file1, skiprows=1, usecols=range(0,9) )
	    Mw = tmp[:,0]
	    Rrup = tmp[:,1]
	    Rjb = tmp[:,2]
	    Rx = tmp[:,3]
	    Dip = tmp[:,4]
	    W = tmp[:,5]
	    Ztor = tmp[:,6]
	    Vs30 = tmp[:,7]
	    Zsed = tmp[:,8] 
	    
	    print '='*30
	    start_time0 = HourMinSecToSec(BlockName='Test file %s starts...'%spl)
	    print '='*30

	    for ip in xrange( self.NT ):
		Ti = self.periods[ip]
		median, std, tau, sigma = NGA08(self.nga, Mw, Rjb, Vs30, Ti, rake=None, Mech=None, Ftype=Ftype, \
						Rrup=Rrup, Rx=Rx, dip=Dip,W=W,Ztor=Ztor,Z25=Zsed,Z10=Zsed, \
						Fas=Fas,Fhw=Fhw,\
						ArbCB=ArbCB,VsFlag=VsFlag)
		if IMT == 'MEDIAN':
		    output = np.array(median)  # in (g)
		if IMT[:3] == 'SIG': 
		    output = np.log(np.array(std) )   # in ln
		tmp = np.c_[ tmp, output ] 
	    
	    print '='*30
	    end_time0 = HourMinSecToSec(BlockName='Test file %s finished...'%spl)
	    hour,min,sec = SecToHourMinSec(end_time0-start_time0,BlockName='Test file %s'%spl)
	    print '='*30 + '\n'


	    # Write into files for comparison
	    outfile = outpth + '/' + spl 
	    fid = open( outfile, 'w' )
	    fid.write( '%s\n'%self.FileHeaders )
	    Nr,Nc = tmp.shape
	    for ir in xrange( Nr ): 
		Str0 = ''
		Str0 += 9*'%s  '%(Mw[ir],Rrup[ir],Rjb[ir],Rx[ir],Dip[ir],W[ir],Ztor[ir],Vs30[ir],Zsed[ir])
		for ic in xrange( Nc-9 ):
		    Str0 += '%s   '%tmp[ir, ic+9]
		Str0 = Str0 + '\n' 
		fid.write( '%s'%Str0 ) 
	    fid.close() 


    def PlotRMS(self, Ratio=True): 
      
	ylab = 'Error RMS'
	if Ratio:
	    ylab = 'Relative Error RMS (%)'

	inpth = self.OFilePth + '/' + self.NGAmodel
	outpth = self.PFilePth + '/' + self.NGAmodel
	Files1 = glob.glob(inpth+'/*') 
	for file1 in Files1: 
	    spl = file1.strip().split('/')[-1]
	    spl0 = spl.strip().split('_')
	    if len(spl0)<=2:
		continue
	    
	    # Python computed NGA values
	    file2 = outpth + '/' + spl 

	    print 'Plot RMS of test file: ', spl
	    tmp = np.loadtxt( file1, skiprows=1 )
	    
	    NGAO = tmp[:,9:self.NT+9]
	    NGAP = np.loadtxt( file2, skiprows=1, usecols=range(9,self.NT+9) ) 

            Error = []
	    for ic in xrange( NGAO.shape[1] ): 
		Err = RMScalc( NGAP[:,ic], NGAO[:,ic],Ratio=False ) 
		Err = Err * (1*(Ratio==False)+100*(Ratio==True))  # convert to % if RMS is relative
		Error.append(Err)

	    fig = plt.figure(1) 
	    fig.clf()
	    ax = fig.add_subplot( 111 ) 
	    xt = self.periods[:-2] 
	    ax.semilogx( xt, Error[:-2], 'ro', xt, np.ones(len(xt))*0.02, 'k--', xt, np.ones(len(xt))*(-0.02), 'k--' )
	    xt = 0.001
	    ax.semilogx( xt, Error[-2], 'go' )
	    xt = 0.005
	    ax.semilogx( xt, Error[-1], 'bo' )

   
	    ax.set_ylabel( ylab )
	    ax.set_ylim([-0.05,0.05])
	    ax.set_ylim([-0.5,0.5])
	    ax.set_xlabel( 'periods' )
	    ax.set_xlim([0.0001,100])
	    ax.set_title( spl[:-4] ) 

	    plotname = self.pltpth1 + '/' + spl[:-3] + self.pfmt    # plot name in full pth
            fig.savefig( plotname, format=self.pfmt )
        
    
    def PlotDiff(self, xlab='Rjb'): 
	
	inpth = self.OFilePth + '/' + self.NGAmodel
	outpth = self.PFilePth + '/' + self.NGAmodel
	
	Files1 = glob.glob(inpth+'/*') 
	for file1 in Files1: 
	    spl = file1.strip().split('/')[-1]
	    spl0 = spl.strip().split('_')
	    if len(spl0)<=2:
		continue
	    
	    # Python computed NGA values
	    file2 = outpth + '/' + spl 

	    print 'Plot differences of test file: ', spl
	    tmp = np.loadtxt( file1, skiprows=1 )
            if xlab == 'Rjb':
		xt = tmp[:,2]
	    if 0:
		Mw = tmp[:,0]
		Rrup = tmp[:,1]
		Rjb = tmp[:,2]
		Rx = tmp[:,3]
		Dip = tmp[:,4]
		W = tmp[:,5]
		Ztor = tmp[:,6]
		Vs30 = tmp[:,7]
		Zsed = tmp[:,8] 
	    NGAO = tmp[:,9:self.NT+9]
	    NGAP = np.loadtxt( file2, skiprows=1, usecols=range(9,self.NT+9) ) 
	    
	    fig = init_fig( num=1, figsize=(14,10), dpi=100 )
	    fig.clf()
            axs = init_subaxes( fig, subs=(4,6), basic=(0.5,0.5,0.5,0.5))
	    for ic in xrange( NGAO.shape[1] ): 
		ax = fig.add_axes( axs[ic] )
		Err = NGAP[:,ic]-NGAO[:,ic] 
		ax.plot( xt, Err, 'r.' )
		if ic == 0: 
		    ax.set_xlabel( xlab )
		    ax.set_ylabel( 'Err' )
		ax.set_title( self.periods[ic] )

	    plotname = self.pltpth2 + '/' + spl[:-3] + self.pfmt    # plot name in full pth
            fig.savefig( plotname, format=self.pfmt )
        
