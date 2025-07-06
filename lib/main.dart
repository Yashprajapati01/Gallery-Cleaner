import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallerycleaner/presentation/bloc/gallery_bloc.dart';
import 'package:gallerycleaner/presentation/screens/delete_screen.dart';
import 'package:gallerycleaner/presentation/screens/gallery_swiper.dart';

import 'di/injection.dart';
import 'package:get_it/get_it.dart';

import 'domain/repository/media_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();

  final repository = GetIt.instance<MediaRepository>();

  runApp(
    BlocProvider(
      create: (_) => GalleryBloc(repository)..add(LoadMedia()),
      child: MaterialApp(
        title: 'Gallery Cleaner',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const GallerySwiperScreen(),
        routes: {
          '/delete-list': (_) => const DeleteListScreen(),
        },
      ),
    ),
  );
}
