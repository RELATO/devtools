/*
 * Criado em 16/04/2004
 *
 */
package br.com.relato.fop.server;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Date;

import org.apache.fop.apps.Driver;
import org.xml.sax.InputSource;

/**
 * @author Rodrigo Kumpera
 *  
 */
public class FopWorker implements Runnable {
	static final int BUFFER_SIZE= 10240;
	private static int job_seq= 0;
	private final Socket socket;
	private final int job;
	private final NumberFormat fmt= new DecimalFormat("###,###,###");
	private boolean dumpErrors;
	
	public FopWorker(final Socket socket, boolean dumpErrors) {
		this.socket= socket;
		this.dumpErrors = dumpErrors;
		job= ++job_seq;
	}

	private Driver getDriver() {
		Driver driver= new Driver();
		driver.setRenderer(Driver.RENDER_PDF);
		return driver;
	}

	public void run() {
		long s= System.currentTimeMillis();
		File tempFile= null;
		InputStream in= null;
		try {
			Main.log("comecando job " + job);

			tempFile= File.createTempFile("fop", "tmp");
			in= new BufferedInputStream(readInputFile(tempFile), BUFFER_SIZE);

			long t= System.currentTimeMillis() - s;

			Main.log("job " + job + " recebeu arquivo em " + t + "ms"
					+ " tamanho " + fmt.format(tempFile.length()));

			final OutputStream out= new BufferedOutputStream(socket
					.getOutputStream(), BUFFER_SIZE);
			Driver driver= getDriver();
			try {
				driver.setOutputStream(out);
				driver.setInputSource(new InputSource(in));
				driver.run();
			} catch(Exception e) {
				if(dumpErrors)
					dumpFile(tempFile);
				throw e;
			}
			s= System.currentTimeMillis() - s;
			out.flush();
			Main.log("job " + job + " terminou arquivo em " + (s - t) + "ms"
					+ " total " + s + "ms");
		}catch(Throwable e) {
			Main.log("job " + job + " erro gerando FOP:", e);
		}finally {
			if(tempFile != null)
				tempFile.delete();
			try {
				socket.close();
			}catch(IOException e) {
				Main.log("job " + job + " erro gerando FOP:", e);
			}
			if(in != null)
				try {
					in.close();
				}catch(IOException e) {
					Main.log("job " + job + " erro gerando FOP:", e);
				}
		}
	}

	/**
	 * @param tempFile
	 * @throws FileNotFoundException
	 * @throws IOException
	 */
	private void dumpFile(File tempFile) throws FileNotFoundException, IOException {
		File ff = new File("error__"+new Date().getTime());
		FileOutputStream fout = null;
		FileInputStream fin = null;
		try {
			fin = new FileInputStream(tempFile);
			fout = new FileOutputStream(ff);
			StreamUtils.copy(fin, fout, BUFFER_SIZE);
		} finally {
			if(fin != null) {
				try {
					fin.close();
				} catch(Exception ee) {
					;
				}
			}
			if(fout != null) {
				try {
					fout.close();
				} catch(Exception ee) {
					;
				}
			}
		}
	}

	private FileInputStream readInputFile(File file) throws IOException {
		FileOutputStream out= new FileOutputStream(file);
		try {
			InputStream in= socket.getInputStream();
			StreamUtils.copy(in, out, BUFFER_SIZE);
		}finally {
			out.close();
		}
		return new FileInputStream(file);
	}
}