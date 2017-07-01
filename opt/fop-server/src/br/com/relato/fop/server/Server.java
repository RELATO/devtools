/*
 * Criado em 16/04/2004
 *
 */
package br.com.relato.fop.server;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

import EDU.oswego.cs.dl.util.concurrent.BoundedBuffer;
import EDU.oswego.cs.dl.util.concurrent.PooledExecutor;

/**
 * @author Rodrigo Kumpera
 *
 */
public class Server implements ServerConstants {
	private ServerSocket server;
	private PooledExecutor executor;
	private boolean dumpErrors = false;

	public Server() {
	}

	public void start() throws IOException, InterruptedException {
		try {
			while (!Thread.interrupted()) {
				Socket sock = server.accept();
				Main.log("socket accepted "+sock.getRemoteSocketAddress());
				executor.execute(new FopWorker(sock, dumpErrors));
			}
		} finally {
			server.close();
		}
	}

	public void init(boolean dumpErrors) throws IOException {
		Main.log("starting thread pool");
		executor = new PooledExecutor(new BoundedBuffer(10), 10);
		executor.waitWhenBlocked();
		executor.setMinimumPoolSize(4);
		executor.setKeepAliveTime(-1);
		executor.createThreads(2);
		this.dumpErrors = dumpErrors;
		
		Main.log("binding fop server to port "+FOP_SERVER_PORT);
		server = new ServerSocket(FOP_SERVER_PORT, BACKLOG);
		server.setReuseAddress(true);
	}
}
