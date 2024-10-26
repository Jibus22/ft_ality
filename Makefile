NAME := ft_ality

all:
	dune build
	cp _build/default/bin/main.exe $(NAME)

clean:
	dune clean

fclean: clean
	rm -f $(NAME)

re: fclean all
