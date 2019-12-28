#### Brief definition of Asynchronous Non-blocking I/O 
_Firstly, to disambiguate this definition we have to separate `Asynchronous` and `Non-blocking` keywords._

_Synchronous Blocking I/O :_

```java
        InputStream is = new FileInputStream(new File("someFile"));
        // have to wait while OS return all bytes, which file contains
        is.read(new byte[file.length()]);
```
_Synchronous Non-Blocking I/O :_

```java
        var fileSize = 1024;
        var channel = FileChannel.open("someFile");
        ByteBuffer buffer = ByteBuffer.allocate(fileSize);

        int bytes = channel.read(buffer);
        
        // check if file was fully readed
        while((fileSize -= bytes) > 0) {
            /*
            * do some another work, while OS delivers next chunk of file bytes,
            * e.g. make some computations on allready delivered chunk of bytes.
            *
            * This allow to gain some performance benefits
            * in contrast to reading all bytes and making all computations later.
            */
            bytes = channel.read(buffer);
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
