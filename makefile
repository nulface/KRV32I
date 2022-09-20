CXX = g++

.PHONY: assemble

assemble:
	$(CXX) *.cpp -o assembler
	./assembler.exe
	#$(CXX) *.o