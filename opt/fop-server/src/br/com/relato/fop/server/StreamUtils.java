/*
 * Criado em 16/04/2004
 *
 */
package br.com.relato.fop.server;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

/**
 * @author administrador
 *
 */
public class StreamUtils {
	public static void copy(InputStream in, OutputStream out, int bufferSize) throws IOException {
		byte[] buffer = new byte[bufferSize];
		int i;
		while((i = in.read(buffer)) != -1) {
			out.write(buffer, 0, i);
		}
	}

/*	public static void copy(InputStream in, OutputStream out, OutputStream out2) throws IOException {
		int i;
		while((i = in.read()) != -1) {
			out.write(i);
			out2.write(i);
		}
	}*/
}
