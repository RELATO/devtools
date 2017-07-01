/*
 * Criado em 16/04/2004
 *
 */
package br.com.relato.fop.server;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.net.InetAddress;
import java.net.Socket;

import junit.framework.TestCase;

/**
 * @author administrador
 *
 */
public class ServerTest extends TestCase {

	private final class ServerRunnable implements Runnable {
		public void run() {
			Server s = new Server();
			try {
				s.init(false);				
				s.start();
			} catch (IOException e) {
				exception = e;
			}catch(InterruptedException e) {
				exception = e;
			}
		}
	}

	public ServerTest(String arg0) {
		super(arg0);
	}

	Exception exception;
	public void testServer() {
		Thread thread = null;
		try {
			thread = new Thread(new ServerRunnable());
			thread.start();
			FileInputStream in = new FileInputStream("teste/lista2.xml");
			Socket socket = new Socket(InetAddress.getLocalHost(), ServerConstants.FOP_SERVER_PORT);

			StreamUtils.copy(in, socket.getOutputStream(), 10000);
			socket.shutdownOutput();
			in.close();
			
			FileOutputStream out = new FileOutputStream("teste/result.pdf");
			StreamUtils.copy(socket.getInputStream(), out, 10000);
			socket.close();
			out.close();
		} catch (IOException e) {
			fail(e.getMessage());
		} finally {
			if(thread != null)
				thread.interrupt();
		}
		assertNull(exception);
		
		
	}
}
