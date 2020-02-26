#### Brief definition of Asynchronous Non-blocking I/O 
_Firstly, to disambiguate this definition we have to separate `Asynchronous` and `Non-blocking` keywords._

_Synchronous Blocking I/O :_

```java
        InputStream is = new FileInputStream(new File("someFile"));
        // have to wait while OS return all bytes, which file contains
        is.read(new byte[file.length()]);
```
_or :_

```java
        var fileSize = 1024;
        var channel = FileChannel.open("someFile");
        ByteBuffer buffer = ByteBuffer.allocate(fileSize);

        int bytes = channel.read(buffer);
        
        // check if file was fully readed
        while((fileSize -= bytes) > 0) {
            /*
            * despite the fact, that Socket Channels in Java 
            * could be configured to work in Non-blocking fashion,
            * the FileChannel.read(...) operation is always blocking
            */
            bytes = channel.read(buffer);
        }
```

_Synchronous Non-Blocking I/O :_
```java
    private static ServerSocketChannel serverSocketChannel;
    private static final ByteBuffer READ_BUF = ByteBuffer.allocate(1024);

    public static void main(String[] args) throws IOException {
        serverSocketChannel = ServerSocketChannel.open();

        Selector selector = serverSocketChannel
                .bind(new InetSocketAddress(60777))
                .configureBlocking(false)
                .register(Selector.open(), SelectionKey.OP_ACCEPT)
                .selector();

        while (true) {
            if (selector.select() != 0) {
                Iterator<SelectionKey> selectedKeysIter = selector.selectedKeys().iterator();

                while (selectedKeysIter.hasNext()) {
                    SelectionKey key = selectedKeysIter.next();

                    selectedKeysIter.remove();

                    if (key.isValid()) {
                        tryAcceptConnection(key);
                        tryRead(key);
                    }
                }
            }
        }
    }

    private static void tryAcceptConnection(SelectionKey key) throws IOException {
        if (key.isAcceptable()) {
            ServerSocketChannel serverChannel = (ServerSocketChannel) key.channel();
            SocketChannel channel = serverChannel.accept();
            channel.configureBlocking(false);
            channel.register(key.selector(), SelectionKey.OP_READ);
        }
    }

    private static void tryRead(SelectionKey key) throws IOException {
        if (key.isReadable()) {

            int readNum = read(key);
            print(readNum);
        }
    }

    /**
     * A read operation might not fill the buffer, and in fact it might not
     * read any bytes at all.  Whether or not it does so depends upon the
     * nature and state of the channel.  A socket channel in non-blocking mode,
     * for example, cannot read any more bytes than are immediately available
     * from the socket's input buffer; similarly, a file channel cannot read
     * any more bytes than remain in the file.  It is guaranteed, however, that
     * if a channel is in blocking mode and there is at least one byte
     * remaining in the buffer then this method will block until at least one
     * byte is read.
     */
    private static int read(SelectionKey key) throws IOException {
        int nRead = ((SocketChannel) key.channel()).read(READ_BUF);
        READ_BUF.clear();

        if (nRead == -1) {
            close(key);
        }

        return nRead;
    }

    private static void print(int readNum) {
        byte[] read = new byte[readNum];
        READ_BUF.get(read);
        out.println("Read: " + new String(read));

        READ_BUF.clear();
    }

    private static void close(SelectionKey key) throws IOException {
        var errorMsg = "Closed by: " + ((SocketChannel) key.channel()).socket()
                        .getRemoteSocketAddress();

        key.channel().close();
        key.cancel();
        serverSocketChannel.close();

        throw new ClosedConnectionException(errorMsg);
    }
```
_Asynchronous Non-Blocking I/O :_

```java
        Future<?> future = Executors.newSingleThreadExecutor()
                                      .submit(() -> { /* read file in Non-Blocking way */});

        /*
        * Make some another Asynchronous work:
        * go get some coffee or compile new linux kernel
        * */
        
        if(future.isDone()) {
            var completedFile = future.get();
        }
```

_So, `Blocking / Non-Blocking` - is a way to communicate with OS IO api, while `Asynchronous` - is a way to execute tasks without interrupting current execution flow._
