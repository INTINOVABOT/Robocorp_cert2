import shutil

def comprimir(Fichero,Carpeta ):
    archivo_zip = shutil.make_archive(Fichero, "zip", Carpeta)

if __name__ == "__main__":
    comprimir()