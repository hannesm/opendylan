import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.io.PrintWriter;
import java.net.Socket;
import java.util.ArrayList;


public class LayouterClient extends Thread {
	private Socket socket;
	private BufferedReader reader;
	private PrintWriter writer;
	private final Symbol connection = new Symbol("connection-identifier"); 
	private ArrayList<IncrementalHierarchicLayout> graphs = new ArrayList<IncrementalHierarchicLayout>();
	
	public LayouterClient (Socket s) {
		try {
			socket = s;
			reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
			writer = new PrintWriter(new OutputStreamWriter(socket.getOutputStream()));
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public IncrementalHierarchicLayout getGraph (int index) {
		return graphs.get(index);
	}
	
	private ArrayList readMessage () throws NumberFormatException, IOException {
		char[] buffer = new char[6];
		if (reader.read(buffer, 0, 6) == 6) {
			String size = "";
			for (int i = 0; i < 6; i++)
				size += Character.toString(buffer[i]);
			int message_length = Integer.parseInt(size, 16);
			return read_s_expression(message_length);
		}
		return null;
	}
	
	public void run() {
		//first ask for connection identifier
		try {
			//ArrayList question = new ArrayList();
			//question.add(connection);
			//printMessage(question);
			ArrayList answer = readMessage();
			assert(answer.size() == 2);
			assert(answer.get(0) instanceof Symbol);
			assert(answer.get(1) instanceof Symbol);
			assert(((Symbol)answer.get(0)).isEqual(connection));
			Symbol identifier = (Symbol)answer.get(1);
			
			DemoBase demo = new DemoBase(identifier.toString(), this);
			demo.start();
			
			while (true) {
				answer = readMessage();
				assert(answer.size() > 2);
				assert(answer.get(0) instanceof Symbol);
				assert(answer.get(1) instanceof Integer);
				int dfm_id = (Integer)answer.get(1);
				Symbol key = (Symbol)answer.get(0);
				if (key.isEqual("initial-dfm") || key.isEqual("optimized-dfm")) {
					assert(answer.size() == 3);
					assert(answer.get(2) instanceof ArrayList);
					System.out.println(key.toString() + " for " + dfm_id + " is " + (ArrayList)answer.get(2));
					IncrementalHierarchicLayout graph = new IncrementalHierarchicLayout(demo);
					ArrayList cf = (ArrayList)answer.get(2);
					assert(cf.size() > 1);
					assert(cf.get(1) instanceof Symbol); //method name
					graphs.add(graph);
					demo.addGraph(dfm_id, ((Symbol)(cf.get(1))).toString());
					graph.activateLayouter();
					graph.initGraph((ArrayList)answer.get(2));
				} else if (key.isEqual("remove-edge")) {
					assert(answer.size() == 4);
					assert(answer.get(2) instanceof Integer);
					assert(answer.get(3) instanceof Integer);
					//IncrementalHierarchicLayout gr = graphs.get(dfm_id);
					int from = (Integer)answer.get(2);
					int to = (Integer)answer.get(3);
					System.out.println("removing edge in graph " + dfm_id + " from " + from + " to " + to);
				} else if (key.isEqual("insert-edge")) {
					assert(answer.size() == 4);
					assert(answer.get(2) instanceof Integer);
					assert(answer.get(3) instanceof Integer);
					//IncrementalHierarchicLayout gr = graphs.get(dfm_id);
					int from = (Integer)answer.get(2);
					int to = (Integer)answer.get(3);
					System.out.println("inserting edge in graph " + dfm_id + " from " + from + " to " + to);
				} else if (key.isEqual("new-computation")) {
					assert(answer.size() == 4);
					assert(answer.get(2) instanceof Integer);
					assert(answer.get(3) instanceof String);
					//IncrementalHierarchicLayout gr = graphs.get(dfm_id);
					int new_id = (Integer)answer.get(2);
					String text = (String)answer.get(3);
					System.out.println("adding node in graph " + dfm_id + " id " + new_id + " text " + text);
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private int compute_s_expression_size (Symbol message) {
		return message.toString().length();
	}
	private void write_s_expression (Symbol message) {
		writer.write(message.toString());
	}
	
	private int compute_s_expression_size (String message) {
		return 2 + message.length();
	}
	private void write_s_expression (String message) {
		writer.write((int)'"');
		writer.write(message);
		writer.write((int)'"');
	}
	
	private int compute_s_expression_size (Integer message) {
		return (Integer.toString(message)).length();
	}
	private void write_s_expression (Integer message) {
		writer.write(Integer.toString(message));
	}
	
	private int compute_s_expression_size (ArrayList message) {
		int size = 1; //'(' + ')'
		for (Object s : message) {
			if (s instanceof String)
				size += compute_s_expression_size((String)s);
			else if (s instanceof Symbol)
				size += compute_s_expression_size((Symbol)s);
			else if (s instanceof Integer)
				size += compute_s_expression_size((Integer)s);
			else if (s instanceof ArrayList)
				size += compute_s_expression_size((ArrayList)s);
			size++; //' '
		}
		return size;
	}
	private void write_s_expression (ArrayList message) {
		int i = message.size();
		writer.write((int)'(');
		for (Object s : message) {
			i--;
			if (s instanceof String)
				write_s_expression((String)s);
			else if (s instanceof Symbol)
				write_s_expression((Symbol)s);
			else if (s instanceof Integer)
				write_s_expression((Integer)s);
			else if (s instanceof ArrayList)
				write_s_expression((ArrayList)s);
			if (i > 0)
				writer.write((int)' ');
		}
		writer.write((int)')');
	}
	
	public void printMessage (ArrayList message) {
		int size = compute_s_expression_size(message);
		String sizeb = Integer.toHexString(size);
		for (int i = sizeb.length(); i < 6; i++)
			writer.write((int)'0');
		writer.write(sizeb);
		write_s_expression(message);
		writer.flush();
	}
	
	private enum ParseState { Number, Symbol, String, Nested };
	
	private boolean isWhitespace (char next) {
		if (next == ' ' | next == '\t' | next == '\n' | next == '\r')
			return true;
		return false;
	}
	
	private boolean isNumeric (char n) {
		if (n == '0' | n == '1' | n == '2' | n == '3' | n == '4' |
				n == '5' | n == '6' | n == '7' | n == '8' | n == '9')
			return true;
		return false;
	}

	private int usedTokens = 0;
	private int level = 0;
	private ArrayList read_s_expression (int message_length) throws IOException {
		level++;
		ArrayList res = new ArrayList();
		ParseState state = ParseState.Nested;
		String result = "";
		boolean first = true;
		for (int i = 0; i < message_length; i++) {
			char next = (char)reader.read();
			//System.out.println("level:" + level + " result:" + result + " i:" + i + " state:" + state + " next:" + next);
			switch (state) {
			case Number:
				if (isWhitespace(next) | next == ')') {
					res.add(Integer.parseInt(result));
					result = "";
					state = ParseState.Nested;
				} else if (isNumeric(next))
					result += Character.toString(next);
				else
					System.out.println("unknown numeric token: " + next + " in " + result);
				break;
			case Symbol:
				if (isWhitespace(next) | next == ')') {
					res.add(new Symbol(result));
					result = "";
					state = ParseState.Nested;
				} else
					result += Character.toString(next);
				break;
			case String:
				if (next == '"') {
					res.add(result);
					result = "";
					state = ParseState.Nested;
				} else {
					if (next == '\\') {
						char nextt = (char)reader.read();
						i++;
						if (nextt == 't') result += "\t";
						else if (nextt == 'r') result += "\r";
						else if (nextt == 'n') result += "\n";
						else result += Character.toString(nextt);
					} else
						result += Character.toString(next);
				}
				break;
			case Nested:
				if (isWhitespace(next)) {
					//do nothing
					break;
				} else if (next == '(') {
					if (first && level == 1) break;
					res.add(read_s_expression(message_length - i - 1));
					i += usedTokens;
				} else if (next == '"') {
					state = ParseState.String;
				} else if (isNumeric(next)) {
					state = ParseState.Number;
					result += Character.toString(next);
				} else if (next == ')') {
					usedTokens = i + 1;
					level--;
					return res;
				} else {
					state = ParseState.Symbol;
					result += Character.toString(next);
				}
				break;
			}
			first = false;
		}
		level--;
		//System.out.println("leaving outer level");
		return res;
	}

}
