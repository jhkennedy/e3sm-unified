#!/bin/bash

check_env () {
  echo "Checking the environment $env_name"
  export CDAT_ANONYMOUS_LOG=no
  python -c "import vcs"
  if [ $? -eq 0 ]; then
    echo "  vcs passed"
  else
    echo "  vcs failed"
    exit 1
  fi
  python -c "import mpas_analysis"
  if [ $? -eq 0 ]; then
    echo "  import mpas_analysis passed"
  else
    echo "  import mpas_analysis failed"
    exit 1
  fi
  mpas_analysis -h
  if [ $? -eq 0 ]; then
    echo "  mpas_analysis passed"
  else
    echo "  mpas_analysis failed"
    exit 1
  fi
  python -c "import livvkit"
  if [ $? -eq 0 ]; then
    echo "  livvkit passed"
  else
    echo "  livvkit failed"
    exit 1
  fi
  livv --version
  if [ $? -eq 0 ]; then
    echo "  livv passed"
  else
    echo "  livv failed"
    exit 1
  fi
  python -c "import IPython"
  if [ $? -eq 0 ]; then
    echo "  IPython passed"
  else
    echo "  IPython failed"
    exit 1
  fi
  python -c "import globus_cli"
  if [ $? -eq 0 ]; then
    echo "  globus_cli passed"
  else
    echo "  globus_cli failed"
    exit 1
  fi
  globus --help
  if [ $? -eq 0 ]; then
    echo "  globus passed"
  else
    echo "  globus failed"
    exit 1
  fi
  python -c "import ILAMB"
  if [ $? -eq 0 ]; then
    echo "  ILAMB passed"
  else
    echo "  ILAMB failed"
    exit 1
  fi
  python -c "import acme_diags"
  if [ $? -eq 0 ]; then
    echo "  import acme_diags passed"
  else
    echo "  import acme_diags failed"
    exit 1
  fi
  e3sm_diags --help
  if [ $? -eq 0 ]; then
    echo "  e3sm_diags passed"
  else
    echo "  e3sm_diags failed"
    exit 1
  fi
  python -c "import zstash"
  if [ $? -eq 0 ]; then
    echo "  import zstash passed"
  else
    echo "  import zstash failed"
    exit 1
  fi
  zstash --help
  if [ $? -eq 0 ]; then
    echo "  zstash passed"
  else
    echo "  zstash failed"
    exit 1
  fi
  zstash --help
  if [ $? -eq 0 ]; then
    echo "  zstash passed"
  else
    echo "  zstash failed"
    exit 1
  fi
  GenerateCSMesh --res 64 --alt --file gravitySam.000000.3d.cubedSphere.g
  if [ $? -eq 0 ]; then
    echo "  tempest-remap passed"
  else
    echo "  tempest-remap failed"
    exit 1
  fi
  if [ $python == "2.7" ]; then
     echo "Checking the environment $env_name"
      processflow -v
      if [ $? -eq 0 ]; then
        echo "  processflow passed"
      else
        echo "  processflow failed"
        exit 1
      fi
  fi

}


# Modify the following to choose which e3sm-unified version(s)
# the python version(s) are installed and whether to make an environment with
# x-windows support under cdat (x), without (nox) or both (nox x).  Typically,
# both x and nox environments should be created.
versions=(1.2.6)
pythons=(3.7 2.7)
x_or_noxs=(nox cdatx)

default_python=3.7
default_x_or_nox=nox

# Any subsequent commands which fail will cause the shell script to exit
# immediately
set -e

world_read="False"
channels="-c conda-forge -c defaults -c e3sm -c cdat/label/v81"

# The rest of the script should not need to be modified
if [[ $HOSTNAME = "cori"* ]] || [[ $HOSTNAME = "dtn"* ]]; then
  base_path="/global/project/projectdirs/acme/software/anaconda_envs/cori/base"
  activ_path="/global/project/projectdirs/acme/software/anaconda_envs"
  group="acme"
elif [[ $HOSTNAME = "acme1"* ]] || [[ $HOSTNAME = "aims4"* ]]; then
  base_path="/usr/local/e3sm_unified/envs/base"
  activ_path="/usr/local/e3sm_unified/envs"
  group="climate"
elif [[ $HOSTNAME = "blueslogin"* ]]; then
  base_path="/lcrc/soft/climate/e3sm-unified/base"
  activ_path="/lcrc/soft/climate/e3sm-unified"
  group="climate"
elif [[ $HOSTNAME = "rhea"* ]]; then
  base_path="/ccs/proj/cli900/sw/rhea/e3sm-unified/base"
  activ_path="/ccs/proj/cli900/sw/rhea/e3sm-unified"
  group="cli900"
  world_read="True"
elif [[ $HOSTNAME = "cooley"* ]]; then
  base_path="/lus/theta-fs0/projects/ccsm/acme/tools/e3sm-unified/base"
  activ_path="/lus/theta-fs0/projects/ccsm/acme/tools/e3sm-unified"
  group="ccsm"
  world_read="True"
elif [[ $HOSTNAME = "compy"* ]]; then
  base_path="/compyfs/software/e3sm-unified/base"
  activ_path="/compyfs/software/e3sm-unified"
  group="users"
elif [[ $HOSTNAME = "gr-fe"* ]] || [[ $HOSTNAME = "wf-fe"* ]]; then
  base_path="/usr/projects/climate/SHARED_CLIMATE/anaconda_envs/base"
  activ_path="/usr/projects/climate/SHARED_CLIMATE/anaconda_envs"
  group="climate"
elif [[ $HOSTNAME = "eleven"* ]]; then
  base_path="/home/xylar/miniconda3"
  activ_path="/home/xylar/Desktop"
  group="xylar"
  channels="$channels --use-local"
else
  echo "Unknown host name $HOSTNAME.  Add env_path and group for this machine to the script."
  exit 1
fi

if [ ! -d $base_path ]; then
  miniconda=Miniconda3-latest-Linux-x86_64.sh
  wget https://repo.continuum.io/miniconda/$miniconda
  /bin/bash $miniconda -b -p $base_path
  rm $miniconda
fi

# activate the new environment
. $base_path/etc/profile.d/conda.sh
conda activate

conda config --add channels conda-forge
conda config --set channel_priority strict
conda update -y --all

for version in "${versions[@]}"
do
  for python in "${pythons[@]}"
  do
    for x_or_nox in "${x_or_noxs[@]}"
    do
      packages="python=$python e3sm-unified=${version}"
      if [ $x_or_nox == "nox" ]; then
        packages="$packages mesalib"
      fi

      if [[ $python == $default_python && $x_or_nox == $default_x_or_nox ]]; then
        suffix=""
      elif [[ $x_or_nox == $default_x_or_nox ]]; then
        suffix=_py${python}
      else
        suffix=_py${python}_${x_or_nox}
      fi

      env_name=e3sm_unified_${version}${suffix}
      if [ ! -d $base_path/envs/$env_name ]; then
        echo creating $env_name
        conda create -n $env_name -y $channels $packages
      else
        echo $env_name already exists
      fi

      conda activate $env_name
      check_env
      conda deactivate

      # make activation scripts
      for ext in sh csh
      do
        if [[ $ext = "sh" ]]; then
          script="if [ -x \"\$(command -v module)\" ] ; then"
          script="${script}"$'\n'"  module unload python"
          script="${script}"$'\n'"fi"
        else
          script=""
        fi
        script="${script}"$'\n'"source ${base_path}/etc/profile.d/conda.${ext}"
        script="${script}"$'\n'"conda activate $env_name"
        file_name=$activ_path/load_latest_e3sm_unified${suffix}.${ext}
        rm -f "$file_name"
        echo "${script}" > "$file_name"
      done
    done
  done
done

# delete the tarballs and any unused packages
conda clean -y -p -t

echo "changing permissions on activation scripts"
chown -R $USER:$group $activ_path/load_latest_e3sm_unified*
if [ $world_read == "True" ]; then
  chmod -R go+r $activ_path/load_latest_e3sm_unified*
  chmod -R go-w $activ_path/load_latest_e3sm_unified*
else
  chmod -R g+r $activ_path/load_latest_e3sm_unified*
  chmod -R g-w $activ_path/load_latest_e3sm_unified*
  chmod -R o-rwx $activ_path/load_latest_e3sm_unified*
fi

echo "changing permissions on environments"
cd $base_path
echo "  changing owner"
chown -R $USER:$group .
if [ $world_read == "True" ]; then
  echo "  adding group/world read"
  chmod -R go+rX .
  echo "  removing group/world write"
  chmod -R go-w .
else
  echo "  adding group read"
  chmod -R g+rX .
  echo "  removing group write"
  chmod -R g-w .
  echo "  removing world read/write"
  chmod -R o-rwx .
fi
echo "  done."

