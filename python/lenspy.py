import numpy as np
import os

__all__ = ['lenspy']

class setup_lenspix_run(object):

    def __init__(self, workspace, Cls_file=None, nsims=1, nside=8192, lmax=10000, output_root='lensed_cmb', 
                 lens_method=1, pol=False, seed_init=0, seed2_init=None, output_unlensed=False, output_phimap=False, 
                 input_gradphi=False, input_phialm=False, gradphi_root=None, phialm_root=None):

        self.home_path = os.getenv('HOME')
        self.host_name = os.getenv('ENV_HOSTNAME')

        self.workspace = workspace

        if (Cls_file is None):
            Cls_file = self.home_path+'/Projects/CMBtools/cosmologist.info/camb/output/base_plikHM_TT_lowTEB_lensing_lenspotentialCls.dat'

        self.cls_file  = Cls_file
        self.nsims     = nsims
        self.nside     = nside
        self.lmax      = lmax
        self.output_root = output_root
        self.lens_method = lens_method
        self.has_pol = pol
        self.seed1_init = seed_init
        self.seed2_init = seed2_init

        self.input_gradphi = input_gradphi
        self.input_phialm = input_phialm

        if (self.input_gradphi and self.input_phialm):
            print "Either gradphi or phialm should be input, not both"
            exit()

        self.gradphi_root = gradphi_root
        self.phialm_root = phialm_root

        self.output_unlensed = output_unlensed
        self.output_phimap = output_phimap

        self.run_name = 'nside_'+str(self.nside)+'_lmax_'+str(self.lmax) + \
                        '_nsims_'+str(self.nsims)
        if (self.has_pol):
            self.run_name += '_pol'

    def create_ini(self, istart=None, iend=None):
        if (istart is None):
            istart = 0
        if (iend is None):
            iend = self.nsims
        
        ini_path = self.workspace+'/'+self.run_name+'/params_ini/'
        if not os.path.exists(ini_path):
            os.makedirs(ini_path)

        for isim in np.arange(istart,iend):
            ini_file = ini_path+'params_'+str(isim)+'.ini'
            with open(ini_file, 'w') as ini:
                ini.write('w8dir = '+self.home_path+'/Projects/CMBtools/healpix/Healpix_3.30_'+self.host_name+'/data/\n')
                ini.write('nside = %d\n' % self.nside)
                ini.write('lmax = %d\n' % self.lmax)
                ini.write('cls_file = %s\n' % self.cls_file)
                ini.write('out_file_root = %s\n' % self.output_root)
                ini.write('out_file_suffix = sim_%d\n' % isim)
                ini.write('lens_method = %d\n'% self.lens_method)
                ini.write('interp_factor = %.4f\n' % (2048.0/self.nside*1.50))
                ini.write('interp_method = 1\n')
                ini.write('mpi_division_method = 3\n')
                ini.write('want_pol = %s\n' % ('T' if self.has_pol else 'F'))
                ini.write('input_gradphi = %s\n' % ('T' if self.input_gradphi else 'F'))
                ini.write('input_phialm = %s\n' % ('T' if self.input_phialm else 'F'))
                if (self.input_gradphi):
                    ini.write('GradPhi_file = %s\n')

