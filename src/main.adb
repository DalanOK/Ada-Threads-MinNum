with Ada.Text_IO; use Ada.Text_IO;
with Ada.Numerics.Discrete_Random;
procedure Main is

   dim : constant integer := 1000;
   thread_num : constant integer := 8;

   arr : array(1..dim) of integer;

   type Value_Index is record
      value : Integer;
      index : Integer;
   end record;

   procedure Init_Arr is
   type randRange is new Integer range 1..dim;
   package Rand_Int is new ada.numerics.discrete_random(randRange);
   use Rand_Int;
   gen : Generator;
   minIndex : Integer;
   begin
   reset(gen);
   minIndex := Integer(random(gen));
   for I in 1..dim loop
      if I = minIndex then
         arr(I) := -10;
         else
            reset(gen);
            arr(i) := Integer(random(gen));
      end if;
         end loop;
   end Init_Arr;

   function part_min(start_index, finish_index : in integer) return Value_Index is
      min : Value_Index := (arr(Start_Index), start_Index);
   begin
      for i in start_index..finish_index loop
         if arr(i) < min.Value then
            min.Value := arr(I);
            min.Index := i;
         end if;
      end loop;
      return min;
   end part_min;

   task type starter_thread is
      entry start(start_index, finish_index : in Integer);
   end starter_thread;

   protected part_manager is
      procedure set_part_min(min : in Value_Index);
      entry get_min(min : out Value_Index);
   private
      tasks_count : Integer := 0;
      min1 : Value_Index := (arr(1), 1);
   end part_manager;

   protected body part_manager is
      procedure set_part_min(min : in Value_Index) is
      begin
         if min.Value < min1.Value then
            min1 := min;
         end if;
         tasks_count := tasks_count + 1;
      end set_part_min;

      entry get_min(min : out Value_Index) when tasks_count = thread_num is
      begin
         min := min1;
      end get_min;

   end part_manager;

   task body starter_thread is
      min : Value_Index;
      start_index, finish_index : Integer;
   begin
      accept start(start_index, finish_index : in Integer) do
         starter_thread.start_index := start_index;
         starter_thread.finish_index := finish_index;
      end start;
      min := part_min(start_index  => start_index,
                      finish_index => finish_index);
      part_manager.set_part_min(min);
   end starter_thread;

   function parallel_min return Value_Index is
      min : Value_Index;
      thread : array(1..thread_num) of starter_thread;
      chunkSize: Integer := dim / thread_num;
      startIndex: Integer := 1;
      endIndex: Integer;
   begin
      for I in 1..(thread_num-1) loop
         endIndex := startIndex + chunkSize;
         thread(I).start(startIndex, endIndex);
         startIndex := endIndex + 1;
      end loop;
      thread(thread_num).start(startIndex, dim);
      part_manager.get_min(min);
      return min;
   end parallel_min;

begin
   Init_Arr;
   declare
      Min_Element : Value_Index := part_min(1, dim);
      Min_Element_Thread : Value_Index := parallel_min;
   begin
      Put_Line("Minimum Element of the array: " & Min_Element.Value'Image);
      Put_Line("Index of the minimum element: " & Min_Element.Index'Image);
      Put_Line("Minimum Element of the array (calculated by parallel_min method): " & Min_Element_Thread.Value'Image);
      Put_Line("Index of the minimum element (calculated by parallel_min method): " & Min_Element_Thread.Index'Image);
    end;
   end Main;
