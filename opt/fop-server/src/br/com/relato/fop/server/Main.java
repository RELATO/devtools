/*
 * Criado em 16/04/2004
 *
 */
package br.com.relato.fop.server;

import java.io.FileOutputStream;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintStream;
import java.util.Properties;

/**
 * @author Rodrigo Kumpera
 *  
 */
public class Main implements ServerConstants {
	public static synchronized void log(String str) {
		System.err.println(str);
	}

	public static synchronized void log(Throwable t) {
		t.printStackTrace(System.err);
	}

	public static synchronized void log(String str, Throwable t) {
		System.err.println(str);
		t.printStackTrace(System.err);
	}

	public static void main(String[] args) {
		Server server= new Server();
		try {
			InputStream in= Main.class.getClassLoader().getResourceAsStream(
					"fop_config.properties");
			OutputStream output;
			OutputStream err;
			boolean dumpErrors;
			if(in == null) {
				output= new FileOutputStream("fop_log_server.log");
				err= new FileOutputStream("fop_log_server_error.log");
				dumpErrors= false;
			}else {
				Properties prop= new Properties();
				prop.load(in);
				output= new FileOutputStream(prop.getProperty(LOG_FILE_KEY));
				err= new FileOutputStream(prop.getProperty(ERROR_FILE_KEY));
				dumpErrors= Integer.parseInt(prop.getProperty(DUMP_ERROR_FILES,
						"0")) == 1;
			}

			System.setOut(new PrintStream(output));
			System.setErr(new PrintStream(err));
			log("Initializing FOP server");
			server.init(dumpErrors);
			log("FOP server ready. Rock'n roll!");
			server.start();
		}catch(Throwable e) {
			log("Problem acepting socket, stacktrace is:", e);
			System.exit(-1);
		}
		System.exit(0);
	}

}