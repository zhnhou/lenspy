import numpy as py
import os

__all__ = ['lenspy']

class setup_lenspix_run(object):

    def __init__(self, workspace, Cls_file, nsims=500, nside=8192, lmax=10000, nsims=1, output_prefix='lensed_cmb', 
                 lens_method=1, pol=False, seed_init=0, output_unlensed=False, output_phimap=False):
        self.workspace = workspace
        self.cls_file  = Cls_file
        self.nsims     = nsims
        self.nside     = nside
        self.lmax      = lmax
        self.nsims     = nsims
        self.output_prefix = output_prefix
        self.lens_method = lens_method
        self.has_pol = pol
        self.seed_init = seed_init
        self.output_unlensed = output_unlensed
        self.output_phimap = output_phimap

        self.home_path = os.getenv('HOME')
        self.host_name = os.getenv('ENV_HOSTNAME')
        self.run_name = 'nside_'+str(self.nside)+'_lmax_'+str(self.lmax)+
        '_nsims_'+str(self.nsims)
        if (self.has_pol):
            self.run_name += '_pol'

    def create_ini(self, istart=None, iend=None):
        if (istart is None):
            istart = 0
        if (iend is None):
            iend = self.nsims

        os.mkdir('scripts/')

        for isim in np.arange(istart,iend):
            ini_file = 'scripts/'+self.run_name+'/params_'+str(isim)+'.ini'
            with open(ini_file, 'w') as ini:
                ini.write('w8dir = '+self.home+'/Projects/CMBtools/healpix/Healpix_3.30_'+self.host_name+'/data/')
                ini.write('nside = %d')

