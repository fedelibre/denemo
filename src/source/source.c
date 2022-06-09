//      source.c
//
//      Copyright 2012 Richard Shann
//
//      This program is free software; you can redistribute it and/or modify
//      it under the terms of the GNU General Public License as published by
//      the Free Software Foundation; either version 3 of the License, or
//      (at your option) any later version.
//
//      This program is distributed in the hope that it will be useful,
//      but WITHOUT ANY WARRANTY; without even the implied warranty of
//      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//      GNU General Public License for more details.
//
//      You should have received a copy of the GNU General Public License
//      along with this program; if not, write to the Free Software
//      Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//      MA 02110-1301, USA.
#include <string.h>
#include "source/source.h"
#include "core/view.h"
#include "core/utils.h"
#ifdef USE_ATRIL
#include <atril-view.h>
#else
#include <evince-view.h>
#endif
#include "source/sourceaudio.h"

static gboolean Dragging;
static GdkPoint DragStart, DragEnd;

typedef struct fileview
{
  gchar *filename;
  EvView *view;
  GList *highlights;//data are GdkRectangle*
} fileview;

static GList *FileViews = NULL;

static gboolean window_state (GtkWidget *win, GdkEventWindowState  *event)
{
  if (event->changed_mask == GDK_WINDOW_STATE_ICONIFIED)
    g_object_set_data (G_OBJECT(win), "uniconified", GINT_TO_POINTER(!g_object_get_data (G_OBJECT(win),  "uniconified")));
  //g_print("Source %x now set to %s uniconified\n", win,  g_object_get_data (G_OBJECT(win),  "uniconified")? "IS":"IS NOT!!!!");
  return FALSE; //allow other handlers
}

static gboolean is_uniconified (GtkWidget *win)
  {
    //g_print("Source %x is %s uniconified\n", win,  g_object_get_data (G_OBJECT(win),  "uniconified")? "IS":"IS NOT!!!!");
#ifdef G_OS_WIN32
	return TRUE;
#endif
    return (gboolean)GPOINTER_TO_INT(g_object_get_data (G_OBJECT(win),  "uniconified"));
  }
  

static void
set_window_position (EvView * view, gint x, gint y, gint page)
{
  EvDocumentModel *model = (EvDocumentModel *) g_object_get_data (G_OBJECT (view), "model");
  ev_document_model_set_page (model, page);
}


static void
get_window_position (EvView * view, gint * x, gint * y, gint * page, gdouble * scale)
{
  GtkAdjustment *adj = g_object_get_data (G_OBJECT (view), "hadj");
  *x = (gint) gtk_adjustment_get_value (adj);
  adj = g_object_get_data (G_OBJECT (view), "vadj");
  *y = gtk_adjustment_get_value (adj);
  EvDocumentModel *model = (EvDocumentModel *) g_object_get_data (G_OBJECT (view), "model");
  *scale = ev_document_model_get_scale (model);
  *page = ev_document_model_get_page (model);
}


#define MARKER (24)
static GdkRectangle Mark;
static GdkRectangle OldMark;

static void
get_window_size (EvView* view, gint * w, gint * h)
{
  GdkWindow *window;
  GtkWidget *top_vbox = gtk_widget_get_toplevel (GTK_WIDGET (view));
  if (!GTK_IS_LAYOUT (top_vbox))
    window = gtk_widget_get_window (GTK_WIDGET (top_vbox));
  else
    window = gtk_layout_get_bin_window (GTK_LAYOUT (top_vbox));
  if (window)
    {
      EvDocumentModel *model;
      model = g_object_get_data (G_OBJECT (view), "model"); //there is no ev_view_get_model(), when there is use it
      gdouble scale = ev_document_model_get_scale (model);
      
#if GTK_MAJOR_VERSION==2
      gdk_drawable_get_size (window, w, h);
#else
      *w = gdk_window_get_width (window);
      *h = gdk_window_get_height (window);
#endif
      *w *= scale;
      *h *= scale;
    }
}




static gboolean
overdraw (cairo_t * cr, GtkWidget* view)
{
  gint x, y, page;
  gdouble scale;
  get_window_position ((EvView*)view, &x, &y, &page, &scale);
  // cairo_scale( cr, Denemo.project->movement->preview_zoom, Denemo.project->movement->preview_zoom );
  cairo_translate (cr, -x, -y);
  fileview *theview = g_object_get_data (G_OBJECT(view), "fileview");
  GList *Highlights = theview->highlights;

  if (Highlights)
    {
        GList *g;
        for (g=Highlights;g;g = g->next)
            {
               GdkRectangle *r = (GdkRectangle*)g->data;
               if (r->width > r->height)
					cairo_set_source_rgba (cr, 0.5, 0.5, 0.5, 0.5);
			   else
					cairo_set_source_rgba (cr, 1.0, 0.0, 0.0, 0.5);
               cairo_rectangle (cr, r->x * scale, r->y * scale, abs(r->width)* scale, abs(r->height)* scale); 
               // cairo_rectangle (cr, r->x , r->y , abs(r->width), abs(r->height));
               cairo_fill (cr); // cairo_clip (cr);//
            }
    }
  if (Dragging)
    {
        gdouble xx = MIN (DragStart.x, DragEnd.x);
        gdouble yy = MIN (DragStart.y, DragEnd.y);
        if ((abs(DragStart.y-DragEnd.y)>0) && (abs(DragStart.x-DragEnd.x)/abs(DragStart.y-DragEnd.y)) < 1)
			 cairo_set_source_rgba (cr, 0.7, 0.0, 0.0, 0.5);
		else	
			cairo_set_source_rgba (cr, 0.5, 0.5, 0.5, 0.5);
      cairo_rectangle (cr, xx * scale, yy * scale, abs(DragStart.x-DragEnd.x) * scale, abs(DragStart.y-DragEnd.y) * scale);
      cairo_fill (cr);
      cairo_set_source_rgb (cr, 0, 0, 0);
      cairo_rectangle (cr, xx * scale, yy * scale, abs(DragStart.x-DragEnd.x) * scale, abs(DragStart.y-DragEnd.y) * scale);   
      cairo_stroke (cr);
    }
  

  if (Mark.width)
    {
      cairo_set_source_rgba (cr, 0.5, 0.5, 1.0, 0.5);
      cairo_rectangle (cr, Mark.x * scale, Mark.y * scale, MARKER, MARKER);     //this is not right once there is space outside the document visible inside the window.
      cairo_fill (cr);
      cairo_set_source_rgb (cr, 0, 0, 0);
      cairo_rectangle (cr, Mark.x * scale, Mark.y * scale, MARKER, MARKER); 
      cairo_stroke (cr);
    }
  if (OldMark.width)
    {
      cairo_set_source_rgba (cr, 1, 0.5, 0.5, 0.5);
      cairo_rectangle (cr, OldMark.x * scale, OldMark.y * scale, MARKER, MARKER);       //this is not right once there is space outside the document visible inside the window.
      cairo_fill (cr);
      cairo_set_source_rgb (cr, 0, 0, 0);
      cairo_rectangle (cr, OldMark.x * scale, OldMark.y * scale, MARKER, MARKER);      
      cairo_stroke (cr);
    }
    
  return TRUE;
}

#if GTK_MAJOR_VERSION==3
static gint
draw_event (GtkWidget * view, cairo_t * cr)
{
  return overdraw (cr, view);
}

#else
static gint
draw_event (GtkWidget * view, GdkEventExpose * event)
{
  /* Setup a cairo context for rendering and clip to the exposed region. */
  cairo_t *cr = gdk_cairo_create (event->window);
  gdk_cairo_region (cr, event->region);
  cairo_clip (cr);
  overdraw (cr, view);
  cairo_destroy (cr);
  return TRUE;
}

#endif

static GList *locate_highlight (GtkWidget *view, gint x, gint y)
{
    fileview *theview = g_object_get_data (G_OBJECT(view), "fileview");
    GList *g;
    for (g = theview->highlights; g; g = g->next)
        {
            GdkRectangle *rect = (GdkRectangle *)g->data;
            if (x > rect->x && (x< rect->x+rect->width) && (y> rect->y) && (y < rect->y + rect->height))
                return g;
        }
  return NULL;  
}

static void remove_highlight (GtkWidget *menu, GList *highlight)
{
    if (highlight)
        {
            fileview *theview = g_object_get_data (G_OBJECT(menu), "fileview");
            g_free (highlight->data);
            theview->highlights = g_list_delete_link (theview->highlights, highlight); 
        }         
}

static void remove_highlights (GtkWidget *view)
{
    fileview *theview = g_object_get_data (G_OBJECT(view), "fileview");
    g_list_free_full (theview->highlights, g_free);
    theview->highlights = NULL;
}

static void help (void)
 {
     infodialog (_("Note! You cannot bring the Source View window in front of the Denemo Display by clicking on it!\nDrag the Display to one side before reading on.\n_______________________________\nTo insert a link at the Denemo cursor position to a point in this document\nright-click on the point.\nLater you will be able to re-open the document at that point by right clicking on the link in the Denemo display.\nTo shade in gray parts of the source that you don't want to see drag over the area.\nUse this for transcribing from a score with many parts to ease following the part from system to system.\nClick on a grayed-out patch to remove it.\nTo mark a place in the score for looking back at drag a line downwards which will show as a red mark - it is just another color of shading."));
 }
        
static gboolean
motion_notify (EvView * view, GdkEventMotion * event)
{
 if (Dragging)
    {gint x, y, page;
      gdouble scale;
      get_window_position (view, &x, &y, &page, &scale);
      x += event->x;
      y += event->y;
      DragEnd.x = x/scale;
      //DragEnd.x = x;///scale;
      DragEnd.y = y/scale;
      //DragEnd.y = y;//y/scale;
      gtk_widget_queue_draw (GTK_WIDGET (view));
    }
  return TRUE;  
}
static gint
button_release (EvView * view, GdkEventButton * event)
{
	if (audio_is_playing () && (Denemo.project->movement->divert_key_event))
		{
			gboolean left = (event->button == 1);
			switch_back_to_main_window ();
			static GdkEventKey synth_event;
			//{type = GDK_KEY_PRESS, window = 0x555556898870, send_event = 0 '\000', time = 72059087, state = 0, keyval = 65293, length = 1, string = 0x55555898afc0 "\r", hardware_keycode = 36, group = 0 '\000', is_modifier = 0}
			//{type = GDK_KEY_PRESS, window = 0x555556898870, send_event = 0 '\000', time = 72302734, state = 0, keyval = 32, length = 1, string = 0x555558945990 " ", hardware_keycode = 65, group = 0 '\000', is_modifier = 0}

			synth_event.type = GDK_KEY_PRESS;
			synth_event.window = event->window;
			synth_event.time = event->time;
			//g_print ("Key val for space %x and Return %x\n", gdk_keyval_from_name ("space"), gdk_keyval_from_name ("Return"));
			synth_event.keyval = left?gdk_keyval_from_name ("space"):gdk_keyval_from_name ("Return");
			synth_event.hardware_keycode = left?65:36;
			synth_event.string = left?" ":"\r";
			synth_event.length = 1;
			synth_event.state = 0;
			synth_event.group = 0;
			synth_event.is_modifier = 0;
			//g_print ("key press name %s\n", dnm_accelerator_name (synth_event.keyval, synth_event.state));
			*Denemo.project->movement->divert_key_event = &synth_event;
			gtk_main_quit ();
			return TRUE;//don't let other handlers act
		}
		
		
    fileview *theview = g_object_get_data (G_OBJECT(view), "fileview");
    if (Dragging && ((abs(DragEnd.x-DragStart.x)>5) || (abs(DragEnd.y-DragStart.y)>5))) //do not allow very small patches, difficult to remove
        {
          GdkRectangle *r = g_malloc (sizeof (GdkRectangle));
          r->x = MIN(DragStart.x, DragEnd.x);
          r->y = MIN(DragStart.y, DragEnd.y);
          r->width = abs (DragStart.x-DragEnd.x);
          r->height = abs (DragStart.y-DragEnd.y);
          theview->highlights = g_list_append (theview->highlights, r);
        }
   else if (event->button==1)
        {
			static gint64 last_time; 
            static gboolean once = FALSE;
			if ((!once) && ((g_get_monotonic_time () - last_time) <2500000))
               {
				    help ();
					once = TRUE;
			   }
         last_time = g_get_monotonic_time ();
        }
    Dragging = FALSE;
    gtk_widget_queue_draw (GTK_WIDGET (view));
    switch_back_to_main_window ();
    return TRUE;  
}

    
static void popup_highlight_menu (GtkWidget *view, GList *highlight, GdkEventButton *event)
{
  GtkWidget *menu = gtk_menu_new ();
  GtkWidget *item = gtk_menu_item_new_with_label (_("Help"));
  gtk_menu_shell_append (GTK_MENU_SHELL (menu), item);
  g_signal_connect_swapped (G_OBJECT (item), "activate", G_CALLBACK (help), NULL);

  item = gtk_menu_item_new_with_label (_("Remove this Shading/Marker"));
  gtk_menu_shell_append (GTK_MENU_SHELL (menu), item);
  g_object_set_data (G_OBJECT (item), "fileview", g_object_get_data (G_OBJECT (view), "fileview"));
  g_signal_connect (G_OBJECT (item), "activate", G_CALLBACK (remove_highlight), highlight);

  item = gtk_menu_item_new_with_label (_("Remove all Shadings/Markers"));
  gtk_menu_shell_append (GTK_MENU_SHELL (menu), item);
  g_signal_connect_swapped (G_OBJECT (item), "activate", G_CALLBACK (remove_highlights), view);
  gtk_widget_show_all (menu);
  gtk_menu_popup (GTK_MENU (menu), NULL, NULL, NULL, NULL, 0, event->time);
}

static gint
button_press (EvView * view, GdkEventButton * event)
{
	if (audio_is_playing () && (Denemo.project->movement->divert_key_event))
		{
		return TRUE;
		}


  if (event->button == 1)
    {
      gint x, y, page;
      gdouble scale;
      get_window_position (view, &x, &y, &page, &scale);

      x += event->x;
      y += event->y;
      
      GList *highlight = locate_highlight (GTK_WIDGET(view), (gint)(x/scale), (gint)(y/scale));
      
      if (highlight)
        {
            popup_highlight_menu (GTK_WIDGET(view), highlight, event); 
        }
    else
        {
      
          DragStart.x = x/scale;
          DragStart.y = y/scale;
          DragEnd.x = DragStart.x;
          DragEnd.y = DragStart.y;
          Dragging = TRUE; 
        }
    }
  else
    {
      gint x, y, page;
      gdouble scale;
      GdkRectangle candidate;
      candidate = Mark;
      get_window_position (view, &x, &y, &page, &scale);
      gchar *filename = g_object_get_data (G_OBJECT (view), "filename");
      x += event->x;
      y += event->y;
      
            GList *highlight = locate_highlight (GTK_WIDGET(view), (gint)(x/scale), (gint)(y/scale));
      
      if (highlight)
        {
            popup_highlight_menu (GTK_WIDGET(view), highlight, event); 
        }
    else
        {
      
      
          gchar *escaped = escape_scheme(filename);
          gchar *text = g_strdup_printf ("(InsertLink \"%s:%d:%d:%d\")", escaped
                      , (gint) (x / scale), (gint) (y / scale), page);
          g_free(escaped);
          Mark.x = (x - MARKER / 2) / scale;
          Mark.y = (y - MARKER / 2) / scale;
          Mark.width = Mark.height = MARKER;
          if (!gdk_rectangle_intersect (&Mark, &candidate, NULL))
            OldMark = candidate;
          gtk_widget_queue_draw (GTK_WIDGET (view));
          g_print ("Calling %s\n", text);
          call_out_to_guile (text);
          switch_back_to_main_window ();
      }
    }
  return FALSE;
}

static void
goto_page (EvView *view, gint page)
{
 EvDocumentModel *model = (EvDocumentModel *) g_object_get_data (G_OBJECT (view), "model");
 ev_document_model_set_page (model, page);
}

static void
change_page (GtkSpinButton * widget, EvView *view)
{
  gint page = (gint)gtk_spin_button_get_value (widget);
  goto_page(view, page - 1);
}
  
static void
next_page (GtkWidget * button, EvView * view)
{
  //ev_view_next_page (view);
  GtkWidget *spinner = (GtkWidget *)g_object_get_data (G_OBJECT (view), "spinner");
  if (spinner)
    gtk_spin_button_set_value (GTK_SPIN_BUTTON(spinner), gtk_spin_button_get_value (GTK_SPIN_BUTTON(spinner))+1.0);
}

static void
prev_page (GtkWidget * button, EvView * view)
{
  //ev_view_previous_page (view);
  GtkWidget *spinner = (GtkWidget *)g_object_get_data (G_OBJECT (view), "spinner");
  if (spinner)
    gtk_spin_button_set_value (GTK_SPIN_BUTTON(spinner), gtk_spin_button_get_value (GTK_SPIN_BUTTON(spinner))-1.0);
}

static void
page_changed (EvDocumentModel *evdocumentmodel, gint old_page,gint new_page, gpointer view)
    {
      GtkWidget *spinner = (GtkWidget *)g_object_get_data (G_OBJECT (view), "spinner");
      if (spinner)
          gtk_spin_button_set_value (GTK_SPIN_BUTTON(spinner), new_page+1.0);
    }


static gchar *locate_file (gchar *filename) {
    if(!g_file_test(filename, G_FILE_TEST_EXISTS)) {
     gchar *basename = g_path_get_basename(filename);
     gchar *pathdir = g_path_get_dirname (Denemo.project->filename->str);
     filename = g_build_filename (pathdir, basename, NULL);
     g_free(basename);
     g_free(pathdir);
    }
    return filename;
}

//~ typedef struct {
  //~ GdkEventType type;
  //~ GdkWindow *window;
  //~ gint8 send_event;
  //~ gint x, y;
  //~ gint width;
  //~ gint height;
//~ } GdkEventConfigure;

static gboolean window_configure_event (GtkWidget *widget,
               GdkEventConfigure  *event, EvView *view)
   {
	EvDocumentModel *model = (EvDocumentModel *) g_object_get_data (G_OBJECT (view), "model");
	Denemo.project->source_scale = (int) 1000 *ev_document_model_get_scale (model);
	if(Denemo.project->source_scale == 0) 
		g_warning("Scale of document is zero!!!");
	Denemo.project->source_x = event->x;
	Denemo.project->source_y = event->y;
	Denemo.project->source_width = event->width;
	Denemo.project->source_height = event->height;
	//g_print ("configure wxh %dx%d x=%d y=%d scale %d\n", Denemo.project->source_width, Denemo.project->source_height, Denemo.project->source_x,Denemo.project->source_y,Denemo.project->source_scale);
	return FALSE;
   }
static EvView *
get_view (gchar * filename)
{
  GFile *file;
  GError *err = NULL;
  EvView *view = NULL;
  GList *g;
  filename = locate_file (filename);
  if (!g_file_test (filename, G_FILE_TEST_EXISTS))
	return NULL;
  for (g = FileViews; g; g = g->next)
    if (!strcmp (((fileview *) g->data)->filename, filename))
      return (((fileview *) g->data)->view);
  file = g_file_new_for_commandline_arg (filename);
  gchar *uri = g_file_get_uri (file);
  g_object_unref (file);
  EvDocument *doc = ev_document_factory_get_document (uri, &err);
  if (err) {
      g_critical("Error creating view from URI <%s> : message was %s", uri, err->message);
      return NULL;
    }
  OldMark.width = Mark.width = 0;
  
  //g_list_free_full (Highlights, g_free);
  //Highlights = NULL;
  
  view = (EvView *) ev_view_new ();
  

  EvDocumentModel *model = ev_document_model_new_with_document (doc);
  //ev_document_model_set_continuous(model, FALSE);

  ev_view_set_model (view, model);
  GtkWidget *top_vbox = gtk_window_new (GTK_WINDOW_TOPLEVEL);
  g_object_set_data (G_OBJECT(top_vbox), "uniconified", GINT_TO_POINTER(TRUE));
#ifndef G_OS_WIN32
  g_signal_connect (G_OBJECT(top_vbox), "window-state-event", G_CALLBACK (window_state), NULL);
#endif  
  
  g_signal_connect (G_OBJECT (top_vbox), "key_press_event", G_CALLBACK (window_keypress_event), NULL);

  
  g_signal_connect (G_OBJECT(model), "page-changed", G_CALLBACK (page_changed), view);
  
  
  // use a dialog when the user clicks instead  gtk_widget_set_tooltip_text (top_vbox, HELP_TEXT);

  gtk_window_set_title (GTK_WINDOW (top_vbox), g_strdup_printf ("Denemo - Source File: %s", filename));


  //g_idle_add ((GSourceFunc) position_source_window, view);
  g_signal_connect (G_OBJECT(top_vbox), "configure-event", G_CALLBACK (window_configure_event), (gpointer)view);
  
  
  if (Denemo.project->source_scale)
    {
		gtk_window_set_default_size (GTK_WINDOW (top_vbox), Denemo.project->source_width, Denemo.project->source_height);
		gtk_window_move (GTK_WINDOW (top_vbox),Denemo.project->source_x, Denemo.project->source_y - 30 /*window decorations take space*/);
	}
  else
    gtk_window_set_default_size (GTK_WINDOW (top_vbox), 600, 750);

  g_signal_connect (G_OBJECT (top_vbox), "delete-event", G_CALLBACK (gtk_widget_hide), NULL);


#if GTK_MAJOR_VERSION==3
  g_signal_connect_after (G_OBJECT (view), "draw", G_CALLBACK (draw_event), NULL);
#else
  g_signal_connect_after (G_OBJECT (view), "expose_event", G_CALLBACK (draw_event), NULL);
#endif



  g_signal_connect (G_OBJECT (view), "button_press_event", G_CALLBACK (button_press), NULL);
  g_signal_connect (G_OBJECT (view), "button_release_event", G_CALLBACK (button_release), NULL);
  g_signal_connect (G_OBJECT (view), "motion_notify_event", G_CALLBACK (motion_notify), NULL);

  
  GtkWidget *main_vbox = gtk_vbox_new (FALSE, 1);
  GtkWidget *main_hbox = gtk_hbox_new (FALSE, 1);
  gtk_container_add (GTK_CONTAINER (top_vbox), main_vbox);
  gtk_box_pack_start (GTK_BOX (main_vbox), main_hbox, FALSE, TRUE, 0);
//FIXM put next etc buttons in hbox
  GtkWidget *button = gtk_button_new_with_label ("Next");
  g_signal_connect (button, "clicked", G_CALLBACK (next_page), (gpointer) view);
  gtk_box_pack_start (GTK_BOX (main_hbox), button, FALSE, TRUE, 0);
  button = gtk_button_new_with_label ("Previous");
  g_signal_connect (button, "clicked", G_CALLBACK (prev_page), (gpointer) view);
  gtk_box_pack_start (GTK_BOX (main_hbox), button, FALSE, TRUE, 0);

  GtkWidget *label = gtk_label_new (_("... or Set Page Number:"));
  gtk_box_pack_start (GTK_BOX (main_hbox), label, FALSE, TRUE, 0);
  GtkWidget *spinner_adj = (GtkWidget *) gtk_adjustment_new (1.0, 1.0, 999.0, 1.0, 1.0, 1.0);
  GtkWidget *spinner = (GtkWidget *) gtk_spin_button_new (GTK_ADJUSTMENT(spinner_adj), 100.0, 0);
  gtk_box_pack_start (GTK_BOX (main_hbox), spinner, FALSE, TRUE, 0);
  g_signal_connect (G_OBJECT (spinner), "value-changed", G_CALLBACK (change_page), view);
  g_object_set_data (G_OBJECT (view), "spinner", spinner);

  GtkAdjustment *viewvadjustment = GTK_ADJUSTMENT (gtk_adjustment_new (1.0, 1.0, 2.0, 1.0, 4.0, 1.0));
  gtk_vscrollbar_new (GTK_ADJUSTMENT (viewvadjustment));

  GtkAdjustment *viewhadjustment = GTK_ADJUSTMENT (gtk_adjustment_new (1.0, 1.0, 2.0, 1.0, 4.0, 1.0));
  gtk_hscrollbar_new (GTK_ADJUSTMENT (viewhadjustment));

  GtkWidget *score_and_scroll_hbox = gtk_scrolled_window_new (viewhadjustment, viewvadjustment);
  gtk_box_pack_start (GTK_BOX (main_vbox), score_and_scroll_hbox, TRUE, TRUE, 0);
  gtk_container_add (GTK_CONTAINER (score_and_scroll_hbox), GTK_WIDGET (view));
  g_object_set_data (G_OBJECT (view), "vadj", viewvadjustment);
  g_object_set_data (G_OBJECT (view), "hadj", viewhadjustment);
  g_object_set_data (G_OBJECT (view), "filename", g_strdup (filename));
  g_object_set_data (G_OBJECT (view), "model", model);

  gtk_widget_show_all (top_vbox);

  fileview *theview = (fileview *) g_malloc0 (sizeof (fileview));
  theview->filename = g_strdup (filename);
  theview->view = view;
  g_object_set_data (G_OBJECT (view), "fileview", theview);
  FileViews = g_list_append (FileViews, theview);

  return view;
}

static gboolean
position_view (EvView * eview, gint x, gint y, gint page)
{
  if (eview == NULL)
    return FALSE;
  set_window_position (eview, x, y, page);
  Mark.width = Mark.height = MARKER;
  Mark.x = x - MARKER / 2;
  Mark.y = y - MARKER / 2;
  OldMark.width = 0;
  gtk_widget_show (gtk_widget_get_toplevel (GTK_WIDGET (eview)));
  gtk_window_present (GTK_WINDOW (gtk_widget_get_toplevel (GTK_WIDGET (eview))));
  return TRUE;
}

gboolean
open_source (gchar * filename, gint x, gint y, gint page)
{
  if (Denemo.non_interactive)
    return FALSE;
  EvView *eview = get_view (filename);
  if (eview==NULL)
	return FALSE;
  gboolean ret = position_view (eview, x, y, page);
  GtkWidget *spinner = (GtkWidget *)g_object_get_data (G_OBJECT (eview), "spinner");
  gtk_spin_button_set_value (GTK_SPIN_BUTTON(spinner), page+1.0);
  write_status (Denemo.project);
  switch_back_to_main_window ();
  return ret;
}

//moves the first un-iconized source window, on Windows iconized is not tracked
gboolean
move_source_window (gint x, gint y)
{
  if (FileViews == NULL)
    return FALSE;
  GList *g;
  for (g = FileViews; g; g=g->next)
    {
      EvView *view = ((fileview *) g->data)->view;
      GtkWidget *top = gtk_widget_get_toplevel (GTK_WIDGET (view));
      if (gtk_widget_get_visible(top) && is_uniconified (top))
        {
          gtk_window_move (GTK_WINDOW (top), x, y);
          break;
        }
    }
  return g != NULL;
}
gboolean
get_source_position (gint *root_x, gint *root_y)
{
  if (FileViews == NULL)
    return FALSE;
  
  GList *g;
  for (g = FileViews; g; g=g->next)
    {
      EvView *view = ((fileview *) g->data)->view;
      GtkWidget *top = gtk_widget_get_toplevel (GTK_WIDGET (view));
      if (gtk_widget_get_visible(top) && is_uniconified (top))
        {
          gtk_window_get_position (GTK_WINDOW (top), root_x, root_y);
          break;
        }
    }
  return g != NULL;
}

