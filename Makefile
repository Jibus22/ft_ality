NAME := ft_ality

all:
	dune build
	cp -f _build/default/bin/main.exe $(NAME)

clean:
	dune clean

fclean: clean
	rm -f $(NAME)

re: fclean all
