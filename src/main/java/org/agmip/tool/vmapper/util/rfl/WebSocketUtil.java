package org.agmip.tool.vmapper.util.rfl;

import ch.qos.logback.classic.Logger;
import java.io.File;
import java.io.IOException;
import java.net.URL;
import java.nio.ByteBuffer;
import java.util.List;
import java.util.Map;
import org.agmip.tool.vmapper.util.JSONObject;
import org.agmip.tool.vmapper.util.rfl.WebSocketMsg.WSAction;
import org.agmip.tool.vmapper.util.rfl.WebSocketMsg.WSStatus;
import org.apache.tika.Tika;
import org.eclipse.jetty.websocket.api.Session;
import org.slf4j.LoggerFactory;

/**
 *
 * @author Meng Zhang
 */
public class WebSocketUtil {
    
    private final static Tika TIKA = new Tika();
    private static final Logger LOG = (Logger) LoggerFactory.getLogger(WebSocketUtil.class);
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status) {
        return sendMsg(receiver, action, status, "");
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, String message) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (message != null && !message.isEmpty()) {
            msg.setMessage(message);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, ByteBuffer data) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (data != null) {
            msg.setData(data);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, ByteBuffer data, JSONObject messages) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (data != null) {
            msg.setData(data);
        }
        if (messages != null) {
            msg.getMsg().putAll(messages);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WSAction action, WSStatus status, JSONObject messages) {
        WebSocketMsg msg = new WebSocketMsg(action, status);
        if (messages != null) {
            msg.getMsg().putAll(messages);
        }
        return sendMsg(receiver, msg);
    }
    
    public static boolean sendMsg(Session receiver, WebSocketMsg msg) {
        try {
            receiver.getRemote().sendString(String.valueOf(msg.getMsg()));
        } catch (IOException ex) {
            LOG.warn(ex.getMessage());
            return false;
        }
        return true;
    }
    
    public static String getRemoteMIMEType(URL url) throws IOException {
        return TIKA.detect(url.openStream());
    }
    
    public static String getRemoteFileName(URL url) throws IOException {
        String fileName;
        Map<String, List<String>> headers = url.openConnection().getHeaderFields();
        List<String> list = headers.get("Content-Disposition");
        if (list != null && !list.isEmpty()) {
            fileName = list.get(0).replaceFirst("(?i)^.*filename=\"?([^\"]+)\"?.*$", "$1");
        } else {
            fileName = new File(url.getFile()).getName();
        }
        return fileName;
    }
}
