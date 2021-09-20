import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivvia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:number_trivvia/features/number_trivia/presentation/widgets/widgets.dart';
import 'package:number_trivvia/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (context) => di<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              // Top half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  if (state is Empty) {
                    return MessageDisplay(
                      message: 'Start searching!',
                    );
                  } else if (state is Loading) {
                    return LoadingWidget();
                  } else if (state is Loaded) {
                    return TriviaDisplay(numberTrivia: state.numberTrivia);
                  } else if (state is Error) {
                    return MessageDisplay(message: state.message);
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height / 3,
                    child: Placeholder(),
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              // Bottom half
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}