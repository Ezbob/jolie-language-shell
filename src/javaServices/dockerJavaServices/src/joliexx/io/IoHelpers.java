package joliexx.io;

import javax.activation.MimetypesFileTypeMap;
import java.io.File;
import java.io.FileNotFoundException;

class IoHelpers {

    private MimetypesFileTypeMap mimeTypesMap = null;

    private void configMimeTypes() {
        mimeTypesMap = new MimetypesFileTypeMap();
        mimeTypesMap.addMimeTypes("image/jpeg jpg jpeg");
        mimeTypesMap.addMimeTypes("image/png png");
        mimeTypesMap.addMimeTypes("image/tiff tiff");
        mimeTypesMap.addMimeTypes("image/x-icon ico");
        mimeTypesMap.addMimeTypes("image/svg+xml svg");
        mimeTypesMap.addMimeTypes("application/xml xml");
        mimeTypesMap.addMimeTypes("application/javascript js");
        mimeTypesMap.addMimeTypes("text/css css");
        mimeTypesMap.addMimeTypes("application/pdf pdf");
        mimeTypesMap.addMimeTypes("application/x-7z-compressed 7z");
        mimeTypesMap.addMimeTypes("application/zip zip");
        mimeTypesMap.addMimeTypes("text/yaml yaml");
        mimeTypesMap.addMimeTypes("application/java-archive jar");
        mimeTypesMap.addMimeTypes("application/java-vm class");
        mimeTypesMap.addMimeTypes("text/x-java-source java");
        mimeTypesMap.addMimeTypes("application/java-serialized-object ser");
        mimeTypesMap.addMimeTypes("application/x-java-jnlp-file jnlp");
        mimeTypesMap.addMimeTypes("application/x-latex latex tex");
        mimeTypesMap.addMimeTypes("application/x-jolie-source ol");
        mimeTypesMap.addMimeTypes("application/x-jolie-interface iol");
    }

    String getMimeType(File file) throws FileNotFoundException {
        if ( !file.exists() ) {
            throw new FileNotFoundException();
        }
        if (mimeTypesMap == null) {
            configMimeTypes();
        }
        return mimeTypesMap.getContentType(file);
    }

    String getMimeType(String filename) throws FileNotFoundException {
        return getMimeType(new File(filename));
    }


}
